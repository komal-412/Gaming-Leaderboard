#!/bin/bash

echo "🧹 Gaming Leaderboard - Clean Restart Script"

# Stop all running containers
echo "🛑 Stopping all containers..."
docker compose down

# Remove any existing containers with the same names
echo "🗑️  Removing existing containers..."
docker rm -f gamingleaderboard-frontend-1 2>/dev/null || true
docker rm -f gamingleaderboard-backend-1 2>/dev/null || true
docker rm -f gamingleaderboard-db-1 2>/dev/null || true
docker rm -f gamingleaderboard-redis-1 2>/dev/null || true
docker rm -f gamingleaderboard-celery_worker-1 2>/dev/null || true
docker rm -f gamingleaderboard-celery_beat-1 2>/dev/null || true

# Remove containers with alternative naming patterns
docker rm -f gaming-leaderboard-frontend-1 2>/dev/null || true
docker rm -f gaming-leaderboard-backend-1 2>/dev/null || true
docker rm -f gaming-leaderboard-db-1 2>/dev/null || true
docker rm -f gaming-leaderboard-redis-1 2>/dev/null || true
docker rm -f gaming-leaderboard-celery_worker-1 2>/dev/null || true
docker rm -f gaming-leaderboard-celery_beat-1 2>/dev/null || true

# Clean up any dangling containers
echo "🧽 Cleaning up dangling containers..."
docker container prune -f

# Optional: Remove volumes (uncomment if you want fresh database)
read -p "Do you want to remove all data volumes? This fixes most DB issues (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "💾 Removing volumes..."
    docker volume rm gamingleaderboard_postgres_data 2>/dev/null || true
    docker volume rm gaming-leaderboard_postgres_data 2>/dev/null || true
    docker volume prune -f
fi

# Check for port conflicts
echo "🔍 Checking for port conflicts..."
if lsof -i :5432 2>/dev/null; then
    echo "⚠️  Port 5432 is in use. Attempting to free it..."
    sudo lsof -ti:5432 | xargs sudo kill -9 2>/dev/null || true
    sleep 2
fi

if lsof -i :3000 2>/dev/null; then
    echo "⚠️  Port 3000 is in use. Attempting to free it..."
    sudo lsof -ti:3000 | xargs sudo kill -9 2>/dev/null || true
    sleep 2
fi

# Clean up networks
echo "🌐 Cleaning up networks..."
docker network prune -f

# Rebuild and start fresh
echo "🔨 Building and starting fresh containers..."
docker compose up --build -d

# Wait for services
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check status
echo "📊 Container status:"
docker compose ps

echo ""
echo "✅ Clean restart completed!"
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend: http://localhost:8000"
echo "👨‍💼 Admin: http://localhost:8000/admin"