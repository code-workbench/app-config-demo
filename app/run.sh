#!/bin/bash

# Script to easily build and run the app config demo

echo "🐳 Building and running App Config Demo..."
echo "==============================================="

# Stop any existing containers
echo "Stopping existing containers..."
docker-compose down

# Build and run with Docker Compose
echo "Building and starting the application..."
docker-compose up --build -d

# Wait a moment for the container to start
sleep 3

# Check if the container is running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Application is running!"
    echo ""
    echo "🌐 Access the application at:"
    echo "   Web UI: http://localhost:8080"
    echo "   API: http://localhost:8080/api/config"
    echo ""
    echo "📊 Current environment variables:"
    echo "   TEST_SETTING: Hello from Docker!"
    echo "   TEST_SECRET: MySecretValue123"
    echo ""
    echo "🔧 To stop the application, run:"
    echo "   docker-compose down"
    echo ""
    echo "📜 To view logs, run:"
    echo "   docker-compose logs -f"
else
    echo "❌ Failed to start the application"
    echo "Check the logs with: docker-compose logs"
fi
