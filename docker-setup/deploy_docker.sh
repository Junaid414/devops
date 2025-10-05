#!/bin/bash
# ----------------------------------------------------------
# Docker Deployment Script for Apache Web App
# Author: Usman
# Branch: features/usman
# ----------------------------------------------------------

set -e  # Exit immediately if a command fails

CONTAINER_NAME="apache-test"
IMAGE_NAME="my-apache-app"

# Step 1: Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "🚫 Docker is not installed or not in PATH."
    echo "Please install Docker before running this script."
    exit 1
fi

# Step 2: Remove any old container with same name
echo "🛑 Stopping and removing any old container..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# Step 3: Build Docker image (using Dockerfile inside this folder)
echo "🧱 Building the Docker image..."
docker build -t $IMAGE_NAME -f Dockerfile ..

# Step 4: Run container
echo "🚀 Starting new container..."
docker run -d --name $CONTAINER_NAME -p 8080:80 $IMAGE_NAME

# Step 5: Display success message
echo "✅ Deployment complete!"
echo "🌐 Visit: http://localhost:8080"

