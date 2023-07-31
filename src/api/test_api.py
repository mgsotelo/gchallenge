from .main import app

import io
import pytest
from fastapi.testclient import TestClient

client = TestClient(app)

def create_csv_file(data):
    csv_content = "\n".join([",".join(row) for row in data])
    return io.BytesIO(csv_content.encode())

def test_upload_csv_valid_data():
    # Test with valid data for 'jobs'
    data = [
        ["job_id", "job_title", "min_salary", "max_salary"],
        ["1", "Engineer", "50000", "80000"],
        ["2", "Manager", "60000", "100000"],
    ]
    file = create_csv_file(data)
    response = client.post("/uploadcsv/jobs", files={"file": ("test.csv", file)})
    assert response.status_code == 200
    assert response.json() == {"message": "Data successfully inserted into jobs table."}

    # Test with valid data for 'departments'
    data = [
        ["department_id", "department_name", "location"],
        ["1", "Engineering", "New York"],
        ["2", "Finance", "London"],
    ]
    file = create_csv_file(data)
    response = client.post("/uploadcsv/departments", files={"file": ("test.csv", file)})
    assert response.status_code == 200
    assert response.json() == {"message": "Data successfully inserted into departments table."}

    # Test with valid data for 'employees'
    data = [
        ["employee_id", "first_name", "last_name", "job_id", "department_id"],
        ["1", "John", "Doe", "1", "1"],
        ["2", "Jane", "Smith", "2", "2"],
    ]
    file = create_csv_file(data)
    response = client.post("/uploadcsv/employees", files={"file": ("test.csv", file)})
    assert response.status_code == 200
    assert response.json() == {"message": "Data successfully inserted into employees table."}

def test_upload_csv_invalid_table_name():
    # Test with invalid table name
    data = [
        ["invalid_id", "invalid_name"],
        ["1", "Test"],
    ]
    file = create_csv_file(data)
    response = client.post("/uploadcsv/invalid_table", files={"file": ("test.csv", file)})
    assert response.status_code == 404
    assert response.json() == {"detail": "Table not found."}

def test_upload_csv_data_type_mismatch():
    # Test with data type mismatch for 'jobs'
    data = [
        ["job_id", "job_title", "min_salary", "max_salary"],
        ["1", "Engineer", "50000", "80000"],
        ["2", "Manager", "60000", "Invalid"],
    ]
    file = create_csv_file(data)
    response = client.post("/uploadcsv/jobs", files={"file": ("test.csv", file)})
    assert response.status_code == 422
    assert "Data type mismatch for column 'max_salary'" in response.json()["detail"]

if __name__ == "__main__":
    pytest.main(["test_app.py"])
