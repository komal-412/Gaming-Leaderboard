#!/bin/bash

echo "🔍 Database Container Diagnostic Script"

# Check if db container exists
echo "📦 Checking database container status..."
docker compose ps db

echo ""
echo "📋 Database container logs (last 50 lines):"
docker compose logs --tail=50 db

echo ""
echo "🔍 Checking port 5432 availability..."
if lsof -i :5432 2>/dev/null; then
    echo "⚠️  Port 5432 is already in use by another process"
    echo "Kill the process or change the port in docker-compose.yml"
else
    echo "✅ Port 5432 is available"
fi

echo ""
echo "💾 Checking Docker resources..."
docker system df

echo ""
echo "🔧 Checking Docker daemon status..."
docker version

echo ""
echo "📊 System resources:"
echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "Disk: $(df -h . | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"

echo ""
echo "🗂️  Checking volume permissions..."
docker volume ls | grep postgres

echo ""
echo "🚀 Suggested fixes:"
echo "1. If port conflict: sudo lsof -ti:5432 | xargs sudo kill -9"
echo "2. If permission issue: docker volume rm gamingleaderboard_postgres_data"
echo "3. If memory issue: increase Docker memory allocation"
echo "4. If disk space issue: docker system prune -f"
echo ""
echo "💡 Quick fix: ./clean_restart.sh and choose 'y' to remove volumes"