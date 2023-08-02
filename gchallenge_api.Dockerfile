FROM python:bullseye

# Copying the files
COPY src/api/ /app/
COPY scripts/app_configuration.sh /app/

# Set the working directory to /app
WORKDIR /app/

# Configure python
RUN pip install --no-cache-dir -r requirements.txt

# Using env variables to run the script
ENV DB_USER=${DB_USER}
ENV DB_PASS=${DB_PASS}
ENV DB_HOST=${DB_HOST}
ENV DB_PORT=${DB_PORT}

WORKDIR /app

# Configure credentials based on the arguments from build
RUN chmod +x app_configuration.sh

# Exposing port
EXPOSE 8888

# Run the Python application
ENTRYPOINT ./app_configuration.sh $DB_USER $DB_PASS $DB_HOST $DB_PORT && uvicorn main:app --port 8888 --host 0.0.0.0 --reload