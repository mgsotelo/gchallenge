import logging
from fastapi import FastAPI, UploadFile, File, HTTPException, Depends
from pandas import DataFrame
from sqlalchemy import create_engine, inspect
from config import settings

app = FastAPI()

# Set up logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Allowed table names
ALLOWED_TABLES = {"jobs", "departments", "employees"}

def create_engine_object():
    """Create a SQLAlchemy engine object based on the database settings."""
    return create_engine(
        f"mysql+mysqlconnector://{settings.DB_USER}:{settings.DB_PASS}@{settings.DB_HOST}:{settings.DB_PORT}/{settings.DB_NAME}", pool_recycle=300, echo=True
    )

def get_table_columns(table_name):
    """Get column names and data types for a given table from the MySQL database."""
    engine = create_engine_object()
    with engine.connect() as con:
        insp = inspect(con)
        columns = insp.get_columns(table_name)
        return {col["name"]: col["type"] for col in columns}

def validate_data_types(table_name, data):
    """Validate the data types of DataFrame columns against the MySQL table columns."""
    table_columns = get_table_columns(table_name)
    for col in data.columns:
        if col not in table_columns:
            raise HTTPException(status_code=422, detail=f"Column '{col}' not found in the table.")
        csv_dtype = str(data[col].dtype)
        table_dtype = str(table_columns[col])
        if csv_dtype != table_dtype:
            raise HTTPException(status_code=422, detail=f"Data type mismatch for column '{col}'. CSV data type: {csv_dtype}, Table data type: {table_dtype}.")

def insert_data(table_name, data):
    """Insert data from a DataFrame into the specified MySQL table."""
    engine = create_engine_object()
    for i in range(0, len(data), 1000):
        batch = data[i:i+1000]
        batch.to_sql(table_name, con=engine, if_exists='append', index=False)

def validate_endpoint(table_name = Depends()):
    """Dependency to validate the provided table_name against allowed values."""
    if table_name not in ALLOWED_TABLES:
        raise HTTPException(status_code=404, detail="Table not found.")
    return table_name

@app.post("/uploadcsv/{endpoint}", tags=["CSV Upload"])
async def upload_csv(endpoint = Depends(validate_endpoint), file: UploadFile = File(...)):
    """
    Upload and insert CSV data into the specified MySQL table.

    - **endpoint**: The name of the endpoint to insert data into. It can only be "jobs", "employees" or "departments"
    - **file**: The CSV file to upload.

    Returns:
    - dict: A message indicating the success of the data insertion.
    """
    try:
        df = DataFrame.read_csv(file.file)
        logger.info(f"CSV data successfully read for table '{endpoint}'.")
        validate_data_types(endpoint, df)
        logger.info(f"CSV data types validated for table '{endpoint}'.")
        insert_data(endpoint, df)
        logger.info(f"Data successfully inserted into table '{endpoint}'.")
        return {"message": f"Data successfully inserted into {endpoint} table."}
    except HTTPException as e:
        logger.error(f"HTTPException occurred: {e}")
        raise e
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")
        raise HTTPException(
            status_code=500, detail="An unexpected error occurred."
        ) from e
