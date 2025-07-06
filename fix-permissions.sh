#!/bin/bash

echo "🔧 Fixing file permissions for Docker containers..."

# Make entrypoint scripts executable
chmod +x backend/entrypoint.sh
chmod +x backend/celery-worker-entrypoint.sh
chmod +x backend/celery-beat-entrypoint.sh

# Make setup and test scripts executable
chmod +x setup.sh
chmod +x test_api.sh

echo "✅ File permissions fixed!"

# Clean up any existing containers and volumes
echo "🧹 Cleaning up existing containers..."
docker compose down -v

# Remove any frontend build artifacts
echo "🗑️  Cleaning frontend build artifacts..."
rm -rf frontend/build
rm -rf frontend/node_modules

# Build and start fresh
echo "🔨 Building and starting containers..."
docker compose up --build