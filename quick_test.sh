#!/bin/bash

echo "🎯 Quick Test - Add Sample Data"

# Check if system is ready
if ! docker compose ps | grep -q "backend.*Up"; then
    echo "❌ System not running. Run: docker compose up -d"
    exit 1
fi

echo "✅ System is running"

# Create a test user and submit scores
echo "👤 Creating test user and submitting scores..."

# Create user via Django shell
USER_ID=$(docker compose exec -T backend python manage.py shell << 'EOF'
from leaderboard.models import User
user, created = User.objects.get_or_create(
    username='testplayer1',
    defaults={'email': 'test@example.com'}
)
print(user.id)
EOF
)

# Clean the USER_ID (remove any extra whitespace)
USER_ID=$(echo $USER_ID | tr -d '\r\n ')

echo "Created user with ID: $USER_ID"

# Submit some scores via API
echo "🎮 Submitting test scores..."

curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d "{\"user_id\": $USER_ID, \"score\": 1500}" | jq '.' 2>/dev/null || echo "Score 1 submitted"

curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d "{\"user_id\": $USER_ID, \"score\": 800}" | jq '.' 2>/dev/null || echo "Score 2 submitted"

curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d "{\"user_id\": $USER_ID, \"score\": 1200}" | jq '.' 2>/dev/null || echo "Score 3 submitted"

# Check results
echo ""
echo "📊 Current Database Status:"
docker compose exec -T db psql -U postgres -d gaming_leaderboard -c "
SELECT 
    'Users' as table_name,
    COUNT(*) as count
FROM leaderboard_user
UNION ALL
SELECT 
    'Sessions' as table_name,
    COUNT(*) as count
FROM leaderboard_gamesession
UNION ALL
SELECT 
    'Leaderboard' as table_name,
    COUNT(*) as count
FROM leaderboard_leaderboard;
"

echo ""
echo "🏆 Leaderboard:"
curl -s http://localhost:8000/api/leaderboard/top/ | jq '.' 2>/dev/null || curl -s http://localhost:8000/api/leaderboard/top/

echo ""
echo "✅ Test completed!"
echo "🌐 Visit: http://localhost:3000"