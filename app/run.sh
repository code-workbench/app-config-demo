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
echo "Waiting for container to start..."
sleep 10

# Check if the container is running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Application container is running!"
    echo ""
    
    # Wait for the application to be ready
    echo "🔍 Waiting for application to be ready..."
    for i in {1..60}; do
        if curl -s http://localhost:8080/api/config > /dev/null 2>&1; then
            echo "✅ Application is ready!"
            break
        fi
        echo "   Attempt $i/60 - waiting..."
        sleep 3
    done
    
    # Final check
    if curl -s http://localhost:8080/api/config > /dev/null 2>&1; then
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
        echo "❌ Application failed to start properly"
        echo "📜 Check the logs with: docker-compose logs"
        echo ""
        echo "🔍 Container status:"
        docker-compose ps
        echo ""
        echo "📜 Recent logs:"
        docker-compose logs --tail=20
    fi
else
    echo "❌ Failed to start the application container"
    echo "Check the logs with: docker-compose logs"
fi