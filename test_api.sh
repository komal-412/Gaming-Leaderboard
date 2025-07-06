#!/bin/bash

# Test API endpoints

echo "🧪 Testing Gaming Leaderboard API..."

# Test submit score
echo "📝 Testing score submission..."
response=$(curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 500}')
echo "Submit Score Response: $response"

# Test get top leaderboard
echo ""
echo "🏆 Testing top leaderboard..."
response=$(curl -s http://localhost:8000/api/leaderboard/top/)
echo "Top Leaderboard Response: $response"

# Test get user rank
echo ""
echo "🔍 Testing user rank lookup..."
response=$(curl -s http://localhost:8000/api/leaderboard/rank/1/)
echo "User Rank Response: $response"

echo ""
echo "✅ API testing completed!"