#!/bin/bash

echo "🎯 Quick Test - Restore Data and Verify System"

# Check if system is ready
if ! docker compose ps | grep -q "backend.*Up"; then
    echo "❌ System not running. Starting services..."
    docker compose up -d
    sleep 30
fi

echo "✅ System is running"

# Run migrations if needed
echo "🗄️  Ensuring migrations are up to date..."
docker compose exec -T backend python manage.py migrate

echo "👤 Creating users and submitting scores..."

# Create users and add game data via Django shell
docker compose exec -T backend python manage.py shell << 'EOF'
from leaderboard.models import User, GameSession, Leaderboard
from django.db.models import Sum
import random

print("Creating sample users...")

# Create sample users
sample_users = []
user_data = [
    ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com'), 
    ('charlie', 'charlie@example.com'),
    ('diana', 'diana@example.com'),
    ('eve', 'eve@example.com'),
    ('player_1', 'player1@example.com'),
    ('player_2', 'player2@example.com'),
    ('admin_user', 'admin@example.com'),
]

for username, email in user_data:
    user, created = User.objects.get_or_create(
        username=username,
        defaults={'email': email, 'is_active': True}
    )
    sample_users.append(user)
    if created:
        print(f"Created: {username}")
    else:
        print(f"Exists: {username}")

print(f"\nTotal users: {User.objects.count()}")

# Create game sessions for each user
print("Creating game sessions...")
sessions_created = 0
for user in sample_users:
    num_sessions = random.randint(5, 12)
    for _ in range(num_sessions):
        score = random.randint(100, 2500)
        game_mode = random.choice(['solo', 'team', 'ranked', 'classic'])
        
        GameSession.objects.create(
            user=user,
            score=score,
            game_mode=game_mode
        )
        sessions_created += 1

print(f"Created {sessions_created} game sessions")

# Update leaderboard
print("Updating leaderboard...")
Leaderboard.objects.all().delete()  # Clear existing

users_with_scores = User.objects.filter(
    game_sessions__isnull=False
).annotate(
    total_score=Sum('game_sessions__score')
).order_by('-total_score')

leaderboard_entries = []
for user in users_with_scores:
    leaderboard_entries.append(Leaderboard(
        user=user,
        total_score=user.total_score,
        rank=0  # Will be calculated on-demand
    ))

if leaderboard_entries:
    Leaderboard.objects.bulk_create(leaderboard_entries)
    print(f"Created {len(leaderboard_entries)} leaderboard entries")

print(f"\nFinal counts:")
print(f"Users: {User.objects.count()}")
print(f"Game Sessions: {GameSession.objects.count()}")
print(f"Leaderboard Entries: {Leaderboard.objects.count()}")
EOF

# Clear cache to show new data
echo ""
echo "🧹 Clearing cache..."
docker compose exec -T redis redis-cli FLUSHALL > /dev/null 2>&1 || echo "Redis not available"

echo ""
echo "📊 Current Database Status:"
docker compose exec -T db psql -U postgres -d gaming_leaderboard -c "
SELECT 
    'Users' as table_name,
    COUNT(*) as count
FROM leaderboard_user
UNION ALL
SELECT 
    'Game Sessions' as table_name,
    COUNT(*) as count
FROM leaderboard_gamesession
UNION ALL
SELECT 
    'Leaderboard' as table_name,
    COUNT(*) as count
FROM leaderboard_leaderboard;
" 2>/dev/null

echo ""
echo "🏆 Top Players:"
curl -s http://localhost:8000/api/leaderboard/top/ | jq -r '.[:5][]? | "\(.rank). \(.username) - \(.total_score) points"' 2>/dev/null || curl -s http://localhost:8000/api/leaderboard/top/

echo ""
echo "✅ Data restored successfully!"
echo "🌐 Visit: http://localhost:3000"
echo ""
echo "🧪 Test API:"
echo "   curl http://localhost:8000/api/leaderboard/top/"
echo "   ./test_submit_api.sh"