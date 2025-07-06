#!/bin/bash

echo "🔍 Troubleshooting Gaming Leaderboard..."

# Check if containers are running
echo "📦 Checking container status:"
docker compose ps

echo ""
echo "🌐 Checking port accessibility:"

# Check if ports are accessible
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend (port 3000) is accessible"
else
    echo "❌ Frontend (port 3000) is not accessible"
fi

if curl -s http://localhost:8000/api/leaderboard/top/ > /dev/null; then
    echo "✅ Backend (port 8000) is accessible"
else
    echo "❌ Backend (port 8000) is not accessible"
fi

echo ""
echo "📋 Frontend container logs (last 20 lines):"
docker compose logs --tail=20 frontend

echo ""
echo "📋 Backend container logs (last 20 lines):"
docker compose logs --tail=20 backend

echo ""
echo "🔧 If frontend shows 404, try:"
echo "1. docker compose restart frontend"
echo "2. Check if frontend container is running: docker compose ps frontend"
echo "3. Check frontend logs: docker compose logs frontend"
echo ""
echo "🚨 If you see container name conflicts, run:"
echo "   chmod +x clean_restart.sh && ./clean_restart.sh"
echo ""
echo "💥 For complete cleanup (removes all data), run:"
echo "   chmod +x force_clean.sh && ./force_clean.sh"