#!/bin/bash

echo "🎯 Gaming Leaderboard - Quick Score Submission Demo"

# Check if backend is running
if ! curl -s http://localhost:8000/api/leaderboard/top/ > /dev/null 2>&1; then
    echo "❌ Backend is not running. Please start with: docker compose up -d"
    exit 1
fi

echo "✅ Backend is running!"

# Submit sample scores
echo ""
echo "📝 Submitting sample scores..."

echo "Submitting score 1500 for user 1..."
curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 1500}' | jq '.' 2>/dev/null || echo "Score submitted (jq not available for formatting)"

echo ""
echo "Submitting score 1200 for user 2..."
curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2, "score": 1200}' | jq '.' 2>/dev/null || echo "Score submitted"

echo ""
echo "Submitting score 1800 for user 3..."
curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 3, "score": 1800}' | jq '.' 2>/dev/null || echo "Score submitted"

echo ""
echo "Submitting another score 800 for user 1..."
curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 800}' | jq '.' 2>/dev/null || echo "Score submitted"

# Show current leaderboard
echo ""
echo "🏆 Current Top Leaderboard:"
curl -s http://localhost:8000/api/leaderboard/top/ | jq '.' 2>/dev/null || curl -s http://localhost:8000/api/leaderboard/top/

# Show specific user rank
echo ""
echo "🔍 User 1 Rank:"
curl -s http://localhost:8000/api/leaderboard/rank/1/ | jq '.' 2>/dev/null || curl -s http://localhost:8000/api/leaderboard/rank/1/

echo ""
echo "✨ Demo completed! Visit http://localhost:3000 to see the frontend"
echo "📚 For more examples, see SCORE_SUBMISSION.md"