#!/bin/bash

echo "🔧 Database Container Fix Script"

# Stop all services
echo "🛑 Stopping all services..."
docker compose down

# Remove database volume if corrupted
echo "💾 Removing potentially corrupted database volume..."
docker volume rm gamingleaderboard_postgres_data 2>/dev/null || true

# Check and kill any processes using port 5432
echo "🔍 Checking for port conflicts on 5432..."
if lsof -i :5432 2>/dev/null; then
    echo "⚠️  Killing processes using port 5432..."
    sudo lsof -ti:5432 | xargs sudo kill -9 2>/dev/null || true
    sleep 2
fi

# Clean up any PostgreSQL containers
echo "🗑️  Removing any existing PostgreSQL containers..."
docker rm -f $(docker ps -aq --filter ancestor=postgres) 2>/dev/null || true

# Clean system if needed
echo "🧹 Cleaning Docker system..."
docker system prune -f

# Start only the database first
echo "🚀 Starting database container alone..."
docker compose up -d db

# Wait and check
echo "⏳ Waiting for database to initialize..."
sleep 20

# Check status
echo "📊 Database container status:"
docker compose ps db

echo ""
echo "📋 Database logs:"
docker compose logs --tail=20 db

# Test connection
echo ""
echo "🔌 Testing database connection..."
if docker compose exec -T db pg_isready -U postgres; then
    echo "✅ Database is ready!"
    
    # Start remaining services
    echo "🚀 Starting remaining services..."
    docker compose up -d
    
    echo "✅ All services started successfully!"
else
    echo "❌ Database connection failed. Check logs above."
    echo "📋 Full database logs:"
    docker compose logs db
fi