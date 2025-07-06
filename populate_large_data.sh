#!/bin/bash

echo "🚀 Gaming Leaderboard - Populate Large Dataset (Building on Existing Users)"

# Check current status
echo "📊 Current Database Status:"
docker compose exec -T db psql -U postgres -d gaming_leaderboard -c "
SELECT 
    'Users' as table_name,
    COUNT(*) as current_count
FROM leaderboard_user
UNION ALL
SELECT 
    'Game Sessions' as table_name,
    COUNT(*) as current_count
FROM leaderboard_gamesession
UNION ALL
SELECT 
    'Leaderboard' as table_name,
    COUNT(*) as current_count
FROM leaderboard_leaderboard;
"

echo ""
echo "Choose population size:"
echo "1) Small (1,000 users, 5,000 sessions) - Fast test"
echo "2) Medium (10,000 users, 50,000 sessions) - Moderate load"
echo "3) Large (100,000 users, 500,000 sessions) - High load"
echo "4) Extra Large (1,000,000 users, 5,000,000 sessions) - Full scale"

read -p "Enter choice (1-4): " choice

case $choice in
    1)
        TARGET_USERS=1000
        SESSIONS_PER_USER=5
        echo "📝 Selected: Small dataset"
        ;;
    2)
        TARGET_USERS=10000
        SESSIONS_PER_USER=5
        echo "📝 Selected: Medium dataset"
        ;;
    3)
        TARGET_USERS=100000
        SESSIONS_PER_USER=5
        echo "📝 Selected: Large dataset"
        ;;
    4)
        TARGET_USERS=1000000
        SESSIONS_PER_USER=5
        echo "📝 Selected: Extra Large dataset"
        ;;
    *)
        echo "Invalid choice, defaulting to Small"
        TARGET_USERS=1000
        SESSIONS_PER_USER=5
        ;;
esac

TOTAL_SESSIONS=$((TARGET_USERS * SESSIONS_PER_USER))

echo ""
echo "📋 Population Plan:"
echo "   Target Users: $TARGET_USERS"
echo "   Sessions per User: $SESSIONS_PER_USER"
echo "   Total Sessions: $TOTAL_SESSIONS"
echo ""

read -p "Continue with this plan? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

start_time=$(date +%s)

echo "⏳ Starting population process..."

# First, create additional users using Django ORM (more reliable than raw SQL)
echo "👥 Creating users via Django ORM..."

docker compose exec -T backend python manage.py shell << EOF
from leaderboard.models import User
from django.db import transaction
import time

target_users = $TARGET_USERS
current_users = User.objects.count()
users_needed = max(0, target_users - current_users)

print(f"Current users: {current_users}")
print(f"Target users: {target_users}")
print(f"Users to create: {users_needed}")

if users_needed > 0:
    print("Creating users in batches...")
    batch_size = 1000
    created_count = 0
    
    for i in range(0, users_needed, batch_size):
        batch_end = min(i + batch_size, users_needed)
        batch_users = []
        
        for j in range(i, batch_end):
            user_num = current_users + j + 1
            batch_users.append(User(
                username=f'user_{user_num}',
                email=f'user_{user_num}@example.com',
                password='pbkdf2_sha256\$260000\$dummy\$dummy',
                is_active=True,
                is_staff=False,
                is_superuser=False
            ))
        
        try:
            with transaction.atomic():
                User.objects.bulk_create(batch_users, ignore_conflicts=True)
                created_count += len(batch_users)
                print(f"Created batch {i//batch_size + 1}: {len(batch_users)} users (Total: {created_count})")
        except Exception as e:
            print(f"Error in batch {i//batch_size + 1}: {e}")
    
    print(f"User creation completed. Final count: {User.objects.count()}")
else:
    print("Sufficient users already exist.")
EOF

# Create game sessions for all users
echo ""
echo "🎮 Creating game sessions..."

docker compose exec -T backend python manage.py shell << EOF
from leaderboard.models import User, GameSession
from django.db import transaction
import random
import time

sessions_per_user = $SESSIONS_PER_USER
users = User.objects.all()[:$TARGET_USERS]
total_users = len(users)

print(f"Creating {sessions_per_user} sessions for {total_users} users...")

batch_size = 1000
created_sessions = 0

for i in range(0, total_users, batch_size):
    batch_users = users[i:i + batch_size]
    batch_sessions = []
    
    for user in batch_users:
        for _ in range(sessions_per_user):
            score = random.randint(50, 5000)
            game_mode = random.choice(['solo', 'team', 'ranked', 'casual'])
            
            batch_sessions.append(GameSession(
                user=user,
                score=score,
                game_mode=game_mode
            ))
    
    try:
        with transaction.atomic():
            GameSession.objects.bulk_create(batch_sessions)
            created_sessions += len(batch_sessions)
            print(f"Batch {i//batch_size + 1}: Created {len(batch_sessions)} sessions (Total: {created_sessions})")
    except Exception as e:
        print(f"Error in sessions batch: {e}")

print(f"Game sessions completed. Total sessions: {GameSession.objects.count()}")
EOF

# Update leaderboard
echo ""
echo "🏆 Updating leaderboard..."

docker compose exec -T backend python manage.py shell << EOF
from leaderboard.models import User, GameSession, Leaderboard
from django.db.models import Sum
from django.db import transaction

print("Clearing existing leaderboard...")
Leaderboard.objects.all().delete()

print("Calculating user totals...")
users_with_scores = User.objects.filter(
    game_sessions__isnull=False
).annotate(
    total_score=Sum('game_sessions__score')
).order_by('-total_score')

print(f"Found {users_with_scores.count()} users with scores")

print("Creating leaderboard entries...")
batch_size = 1000
leaderboard_entries = []

for rank, user in enumerate(users_with_scores, 1):
    leaderboard_entries.append(Leaderboard(
        user=user,
        total_score=user.total_score,
        rank=rank
    ))
    
    if len(leaderboard_entries) >= batch_size:
        Leaderboard.objects.bulk_create(leaderboard_entries)
        print(f"Created leaderboard batch: {len(leaderboard_entries)} entries")
        leaderboard_entries = []

# Create remaining entries
if leaderboard_entries:
    Leaderboard.objects.bulk_create(leaderboard_entries)
    print(f"Created final batch: {len(leaderboard_entries)} entries")

print(f"Leaderboard completed. Total entries: {Leaderboard.objects.count()}")
EOF

# Clear cache to show new data
echo ""
echo "🧹 Clearing cache..."
docker compose exec -T redis redis-cli FLUSHALL > /dev/null

end_time=$(date +%s)
duration=$((end_time - start_time))

echo ""
echo "✅ Population completed!"
echo "⏱️  Total time: ${duration} seconds"

# Show final statistics
echo ""
echo "📊 Final Database Statistics:"
docker compose exec -T db psql -U postgres -d gaming_leaderboard -c "
SELECT 
    'Users' as table_name,
    COUNT(*) as record_count,
    pg_size_pretty(pg_total_relation_size('leaderboard_user')) as table_size
FROM leaderboard_user
UNION ALL
SELECT 
    'Game Sessions' as table_name,
    COUNT(*) as record_count,
    pg_size_pretty(pg_total_relation_size('leaderboard_gamesession')) as table_size
FROM leaderboard_gamesession
UNION ALL
SELECT 
    'Leaderboard' as table_name,
    COUNT(*) as record_count,
    pg_size_pretty(pg_total_relation_size('leaderboard_leaderboard')) as table_size
FROM leaderboard_leaderboard;
"

echo ""
echo "🏆 Top 10 Players:"
curl -s http://localhost:8000/api/leaderboard/top/ | jq -r '.[] | "\(.rank). \(.username) - \(.total_score) points"' 2>/dev/null || curl -s http://localhost:8000/api/leaderboard/top/

echo ""
echo "🎯 Test the system:"
echo "   Frontend: http://localhost:3000"
echo "   API Top 10: curl http://localhost:8000/api/leaderboard/top/"
echo "   User Rank: curl http://localhost:8000/api/leaderboard/rank/1/"
echo ""
echo "📈 Performance testing: ./performance_test.sh"