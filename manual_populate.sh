#!/bin/bash

echo "🛠️  Manual Database Population Script"

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! docker compose ps | grep -q "backend.*Up"; then
    echo "❌ Backend not running. Starting services..."
    docker compose up -d
    sleep 30
fi

if ! docker compose exec -T db pg_isready -U postgres; then
    echo "❌ Database not ready"
    exit 1
fi

echo "✅ Prerequisites met"

# Run migrations first
echo "🗄️  Running Django migrations..."
docker compose exec -T backend python manage.py migrate

# Check if tables exist
echo "📋 Checking table structure..."
docker compose exec -T db psql -U postgres -d gaming_leaderboard -c "\d leaderboard_user"

# Create a few test users first
echo "👥 Creating test users..."
docker compose exec -T backend python manage.py shell << 'EOF'
from leaderboard.models import User, GameSession, Leaderboard

# Create test users
for i in range(1, 11):
    user, created = User.objects.get_or_create(
        username=f'testuser_{i}',
        defaults={
            'email': f'testuser_{i}@example.com',
            'password': 'pbkdf2_sha256$260000$dummy$dummy'
        }
    )
    if created:
        print(f"Created user: {user.username}")
    else:
        print(f"User exists: {user.username}")

print(f"Total users: {User.objects.count()}")
EOF

# Add some game sessions
echo "🎮 Creating game sessions..."
docker compose exec -T backend python manage.py shell << 'EOF'
from leaderboard.models import User, GameSession, Leaderboard
import random

users = User.objects.all()[:10]
sessions_created = 0

for user in users:
    # Create 3-5 game sessions per user
    for _ in range(random.randint(3, 5)):
        score = random.randint(100, 2000)
        GameSession.objects.create(
            user=user,
            score=score,
            game_mode=random.choice(['solo', 'team'])
        )
        sessions_created += 1

print(f"Created {sessions_created} game sessions")
print(f"Total sessions: {GameSession.objects.count()}")
EOF

# Update leaderboard
echo "🏆 Updating leaderboard..."
docker compose exec -T backend python manage.py shell << 'EOF'
from leaderboard.models import User, GameSession, Leaderboard
from django.db.models import Sum

# Clear existing leaderboard
Leaderboard.objects.all().delete()

# Calculate totals and create leaderboard entries
users_with_scores = User.objects.filter(game_sessions__isnull=False).annotate(
    total_score=Sum('game_sessions__score')
).order_by('-total_score')

leaderboard_entries = []
for rank, user in enumerate(users_with_scores, 1):
    leaderboard_entries.append(
        Leaderboard(
            user=user,
            total_score=user.total_score,
            rank=rank
        )
    )

Leaderboard.objects.bulk_create(leaderboard_entries)
print(f"Created {len(leaderboard_entries)} leaderboard entries")
EOF

# Show results
echo ""
echo "📊 Final Results:"
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
"

echo ""
echo "🏆 Top 5 Players:"
docker compose exec -T db psql -U postgres -d gaming_leaderboard -c "
SELECT 
    u.username,
    l.total_score,
    l.rank
FROM leaderboard_leaderboard l
JOIN leaderboard_user u ON l.user_id = u.id
ORDER BY l.rank
LIMIT 5;
"

echo ""
echo "✅ Manual population completed!"
echo "🌐 Test at: http://localhost:3000"
echo "🔧 API test: curl http://localhost:8000/api/leaderboard/top/"