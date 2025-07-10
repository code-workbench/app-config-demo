#!/bin/bash

# Test script for the app config demo application

echo "🧪 Testing App Config Demo Application"
echo "======================================"

# Set test environment variables
export TEST_SETTING="Local Test Setting"
export TEST_SECRET="LocalSecret123"

echo "📝 Set environment variables:"
echo "   TEST_SETTING=$TEST_SETTING"
echo "   TEST_SECRET=$TEST_SECRET"
echo ""

# Build and run the application in the background
echo "🔨 Building application..."
dotnet build --nologo -v q

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🚀 Starting application..."
    echo "   Press Ctrl+C to stop"
    echo ""
    dotnet run --urls="http://localhost:8080"
else
    echo "❌ Build failed!"
    exit 1
fi
