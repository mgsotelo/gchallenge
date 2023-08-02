#!/bin/bash

# Function to display script usage
usage() {
  echo "Usage: $0 [-b] [-p]"
  echo "  -b    Build the Docker image"
  echo "  -p    Push the Docker image to the registry"
  exit 1
}

# Dockerfile path (replace with your Dockerfile path)
DOCKERFILE="app.Dockerfile"

# Docker image name (replace with your desired image name)
IMAGE_NAME="myuser/myimage"

# Docker image tag (replace with your desired image tag)
IMAGE_TAG="latest"

# Docker registry URL (replace with your registry URL if using a private registry)
REGISTRY_URL=""

# Check for command-line arguments
while getopts "bp" opt; do
  case $opt in
    b) BUILD_IMAGE=1 ;;
    p) PUSH_IMAGE=1 ;;
    \?) usage ;;
  esac
done

# If no flags are provided, show script usage
if [ "$#" -eq 0 ]; then
  usage
fi

# Log in to the Docker registry (optional if using a private registry)
# docker login

# Build the Docker image
if [ -n "$BUILD_IMAGE" ]; then
  docker build \
    --build-arg DB_USER=myuser \
    --build-arg DB_PASS=mypassword \
    --build-arg DB_HOST=myhost \
    --build-arg DB_PORT=3306 \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" -f "${DOCKERFILE}" .

  # Tag the Docker image with the registry URL (if using a private registry)
  if [ -n "${REGISTRY_URL}" ]; then
    docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}"
  fi

  echo "Docker build completed."
fi

# Push the Docker image to the registry
if [ -n "$PUSH_IMAGE" ]; then
  docker push "${IMAGE_NAME}:${IMAGE_TAG}"

  # Push the Docker image with the registry URL (if using a private registry)
  if [ -n "${REGISTRY_URL}" ]; then
    docker push "${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}"
  fi

  echo "Docker push completed."

fi
