# Requiring args
ARG DB_USER
ARG DB_PASS
ARG DB_HOST
ARG DB_PORT

FROM python:3.10.6-alpine

# Set environment variables (optional but recommended)
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create a non-root user and group
RUN groupadd -r myuser && useradd -r -g myuser myuser

# Copying the files
COPY src/api/ /app/
COPY src/scripts/app_configuration.sh /app/

# Set the working directory to /app
WORKDIR /app

# Configure python
RUN pip install --no-cache-dir -r requirements.txt
RUN chown -R myuser:myuser /app

# Switch to the non-root user
USER myuser

# Using env variables to run the script
ENV DB_USER=${DB_USER}
ENV DB_PASS=${DB_PASS}
ENV DB_HOST=${DB_HOST}
ENV DB_PORT=${DB_PORT}

# Configure credentials based on the arguments from build
RUN chmod +x app_configuration.sh
RUN ./app_configuration.sh ${DB_USER} ${DB_PASS} ${DB_HOST} ${DB_PORT}

# Exposing port
EXPOSE 8888

# Run the Python application
CMD uvicorn main:app --port 8888 --reload