import uvicorn
from config import settings
import mysql.connector

from fastapi import FastAPI, UploadFile, File
from fastapi.responses import PlainTextResponse
import csv


app = FastAPI()

# Función para procesar CSV y hacer inserciones en la base de datos
async def process_csv_data(file_path, table_name, contents):
    batch_size = 1000
    data_batch = []

    if table_name == "departments":
        headers = ["id","department"]
    elif table_name == "employees":
        headers = ["id", "name", "datetime", "department_id", "job_id"]
    elif table_name == "jobs":
        headers = ["id", "job"]

    with open(file_path, 'wb') as csvfile:
        csvfile.write(contents)
        csvfile.close()
    
    with open(file_path, 'r') as csvfile:
        csvreader = csv.reader(csvfile)
        for row in csvreader:
            index = row.index('') if '' in row else -1
            if index != -1:
                continue
            if table_name == "employees":
                row[2] = str(row[2]).replace('T',' ').replace('Z','') 
            if data_batch == []:
                data_batch.append(headers)
            data_batch.append(row)
            if len(data_batch) == batch_size+1:
                await insert_data_batch(data_batch, table_name)
                data_batch = []

        if data_batch:
            await insert_data_batch(data_batch, table_name)

# Función para insertar lote de datos en la tabla correspondiente
async def insert_data_batch(data_batch, table_name):
    connection = mysql.connector.connect(
        host=settings.DB_HOST,
        user=settings.DB_USER,
        password=settings.DB_PASS,
        database=settings.DB_NAME,
        port=settings.DB_PORT
    )
    cursor = connection.cursor()

    placeholders = ', '.join(['%s'] * len(data_batch[0]))
    columns = ', '.join(data_batch[0])

    # Se construye la consulta con el lote de datos
    query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
    values = [tuple(row) for row in data_batch[1:]]

    # Ejecutar la consulta
    cursor.executemany(query, values)
    connection.commit()

    cursor.close()
    connection.close()

# Endpoint para procesar los archivos CSV
@app.post("/jobs/csvdata", response_class=PlainTextResponse)
async def process_jobs_csvdata(csv_file: UploadFile = File(...)):
    contents = csv_file.file.read()
    await process_csv_data(csv_file.filename, "jobs", contents)
    return "CSV data processing started for jobs."

@app.post("/departments/csvdata", response_class=PlainTextResponse)
async def process_departments_csvdata(csv_file: UploadFile = File(...)):
    contents = csv_file.file.read()
    await process_csv_data(csv_file.filename, "departments", contents)
    return "CSV data processing started for departments."

@app.post("/employees/csvdata", response_class=PlainTextResponse)
async def process_employees_csvdata(csv_file: UploadFile = File(...)):
    contents = csv_file.file.read()
    await process_csv_data(csv_file.filename, "employees", contents)
    return "CSV data processing started for employees."


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8888)