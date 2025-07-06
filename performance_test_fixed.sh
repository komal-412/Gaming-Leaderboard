#!/bin/bash

echo "⚡ Performance Testing - Gaming Leaderboard (Fixed Version)"

# Function to measure API performance with timeout
measure_api_performance() {
    local endpoint=$1
    local description=$2
    local timeout=${3:-10}
    
    echo "Testing: $description"
    
    # Test with timeout
    total_time=0
    successful_requests=0
    
    for i in {1..3}; do  # Reduced from 5 to 3 for faster testing
        start=$(date +%s%N)
        
        if timeout $timeout curl -s "$endpoint" > /dev/null 2>&1; then
            end=$(date +%s%N)
            duration=$(( (end - start) / 1000000 )) # Convert to milliseconds
            total_time=$((total_time + duration))
            successful_requests=$((successful_requests + 1))
        else
            echo "  Request $i: TIMEOUT or FAILED"
        fi
    done
    
    if [ $successful_requests -gt 0 ]; then
        avg_time=$((total_time / successful_requests))
        echo "  Average response time: ${avg_time}ms (${successful_requests}/3 successful)"
    else
        echo "  ❌ All requests failed"
    fi
    echo ""
}

# Test different endpoints with timeouts
echo "🚀 Starting performance tests with timeouts..."
echo ""

# Check if backend is responding at all
if ! curl -s --max-time 5 http://localhost:8000 >/dev/null; then
    echo "❌ Backend not responding. Check with: ./diagnose_performance_issue.sh"
    exit 1
fi

measure_api_performance "http://localhost:8000/api/leaderboard/top/" "Top 10 Leaderboard (Cached)" 10

measure_api_performance "http://localhost:8000/api/leaderboard/rank/1/" "User Rank Lookup (User #1)" 10

# Get a valid user ID for testing
test_user_id=$(docker compose exec -T backend python manage.py shell -c "
from leaderboard.models import User
user = User.objects.filter(is_superuser=False).first()
print(user.id if user else '1')
" 2>/dev/null | tail -1 | tr -d '\r\n ')

echo "Testing: Score Submission Performance (User ID: $test_user_id)"
total_time=0
successful_submissions=0

for i in {1..3}; do  # Reduced for faster testing
    score=$((RANDOM % 1000 + 1))
    
    start=$(date +%s%N)
    
    # Use timeout for score submission
    if timeout 15 curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
      -H "Content-Type: application/json" \
      -d "{\"user_id\": $test_user_id, \"score\": $score}" > /dev/null 2>&1; then
        
        end=$(date +%s%N)
        duration=$(( (end - start) / 1000000 ))
        total_time=$((total_time + duration))
        successful_submissions=$((successful_submissions + 1))
        echo "  Submission $i: ${duration}ms"
    else
        echo "  Submission $i: TIMEOUT (>15s) or FAILED"
    fi
done

if [ $successful_submissions -gt 0 ]; then
    avg_time=$((total_time / successful_submissions))
    echo "  Average submission time: ${avg_time}ms (${successful_submissions}/3 successful)"
else
    echo "  ❌ All score submissions failed or timed out"
    echo "  🔧 Run: ./fix_performance_issues.sh"
fi

echo ""

# Quick database stats (with timeout)
echo "📊 Quick Database Performance Check:"
timeout 10 docker compose exec -T db psql -U postgres -d gaming_leaderboard -c "
SELECT 
    'Users' as table_name,
    COUNT(*) as records,
    pg_size_pretty(pg_total_relation_size('leaderboard_user')) as size
FROM leaderboard_user
UNION ALL
SELECT 
    'Sessions' as table_name,
    COUNT(*) as records,
    pg_size_pretty(pg_total_relation_size('leaderboard_gamesession')) as size
FROM leaderboard_gamesession
UNION ALL
SELECT 
    'Leaderboard' as table_name,
    COUNT(*) as records,
    pg_size_pretty(pg_total_relation_size('leaderboard_leaderboard')) as size
FROM leaderboard_leaderboard;
" 2>/dev/null || echo "Database query timed out"

echo ""
echo "🎯 Performance Test Summary:"
echo "================================"

if [ $successful_submissions -eq 0 ]; then
    echo "🚨 CRITICAL: Score submission API is not working"
    echo ""
    echo "🔧 Immediate actions:"
    echo "   1. ./diagnose_performance_issue.sh - Detailed diagnosis"
    echo "   2. ./fix_performance_issues.sh - Apply fixes"
    echo "   3. docker compose restart - Restart all services"
    echo "   4. Check logs: docker compose logs backend"
elif [ $avg_time -gt 5000 ]; then
    echo "⚠️  SLOW: Score submission is working but very slow (>${avg_time}ms)"
    echo ""
    echo "🔧 Optimization needed:"
    echo "   1. Reduce dataset size"
    echo "   2. Add database indexes"
    echo "   3. Optimize rank calculation"
else
    echo "✅ Performance appears acceptable"
    echo ""
    echo "📈 Results:"
    echo "   Score submission: ${avg_time}ms average"
    echo "   Success rate: ${successful_submissions}/3"
fi

echo ""
echo "💡 For detailed analysis: ./diagnose_performance_issue.sh"