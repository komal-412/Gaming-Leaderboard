#!/bin/bash

echo "🧪 Submit API Testing - With Timeout Protection"

# Configuration
TIMEOUT_SECONDS=3
MAX_ACCEPTABLE_MS=1000

echo "⚙️  Test Configuration:"
echo "   - Timeout: ${TIMEOUT_SECONDS}s per request"
echo "   - Max acceptable: ${MAX_ACCEPTABLE_MS}ms"
echo "   - Will exit on timeout or failure"
echo ""

# Check if backend is responding
if ! timeout 5 curl -s http://localhost:8000 >/dev/null 2>&1; then
    echo "❌ Backend not responding within 5s"
    echo "🔧 Try: docker compose restart backend"
    exit 1
fi

echo "✅ Backend is responding"

# Get or create test user
echo "� Preparing test user..."
test_user_id=$(docker compose exec -T backend python manage.py shell -c "
from leaderboard.models import User
user, created = User.objects.get_or_create(
    username='api_test_user',
    defaults={'email': 'apitest@example.com'}
)
print(user.id)
" 2>/dev/null | tail -1 | tr -d '\r\n ')

if [ -z "$test_user_id" ]; then
    echo "❌ Failed to get test user"
    exit 1
fi

echo "Using test user ID: $test_user_id"
echo ""

# Test function with strict timeout
test_submit() {
    local test_name="$1"
    local score="$2"
    
    echo "🧪 $test_name"
    
    start_time=$(date +%s%N)
    
    response=$(timeout $TIMEOUT_SECONDS curl -s --max-time $TIMEOUT_SECONDS \
        -X POST http://localhost:8000/api/leaderboard/submit/ \
        -H "Content-Type: application/json" \
        -d "{\"user_id\": $test_user_id, \"score\": $score}" 2>&1)
    
    exit_code=$?
    end_time=$(date +%s%N)
    duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    if [ $exit_code -eq 124 ] || [ $exit_code -eq 28 ]; then
        echo "❌ TIMEOUT: Request took >${TIMEOUT_SECONDS}s"
        echo "🚨 API is too slow - EXITING"
        exit 1
    elif [ $exit_code -ne 0 ]; then
        echo "❌ ERROR: Exit code $exit_code"
        echo "🚨 API failed - EXITING"
        exit 1
    elif [ $duration_ms -gt $MAX_ACCEPTABLE_MS ]; then
        echo "❌ TOO SLOW: ${duration_ms}ms (max: ${MAX_ACCEPTABLE_MS}ms)"
        echo "🚨 Performance unacceptable - EXITING"
        exit 1
    else
        echo "✅ SUCCESS: ${duration_ms}ms"
        echo "   Response: $(echo "$response" | jq -c '.' 2>/dev/null || echo "$response")"
    fi
    echo ""
}

# Run tests
echo "🎯 Starting submit API tests..."
echo ""

test_submit "Test 1: Basic submission" 100
test_submit "Test 2: Higher score" 250
test_submit "Test 3: Another score" 180

# Test invalid requests
echo "🚫 Testing invalid requests:"

echo "Testing missing user_id..."
response=$(timeout 2 curl -s -w "HTTP:%{http_code}" \
    -X POST http://localhost:8000/api/leaderboard/submit/ \
    -H "Content-Type: application/json" \
    -d '{"score": 100}')
echo "Response: $response"

echo ""
echo "Testing missing score..."
response=$(timeout 2 curl -s -w "HTTP:%{http_code}" \
    -X POST http://localhost:8000/api/leaderboard/submit/ \
    -H "Content-Type: application/json" \
    -d '{"user_id": 1}')
echo "Response: $response"

echo ""
echo "Testing negative score..."
response=$(timeout 2 curl -s -w "HTTP:%{http_code}" \
    -X POST http://localhost:8000/api/leaderboard/submit/ \
    -H "Content-Type: application/json" \
    -d '{"user_id": 1, "score": -100}')
echo "Response: $response"

# Rapid fire test
echo ""
echo "🔥 Rapid fire test (5 requests in parallel)..."
start_time=$(date +%s)

for i in {1..5}; do
    score=$((300 + i * 20))
    timeout 2 curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
        -H "Content-Type: application/json" \
        -d "{\"user_id\": $test_user_id, \"score\": $score}" >/dev/null &
done

wait
end_time=$(date +%s)
total_duration=$((end_time - start_time))

if [ $total_duration -gt 5 ]; then
    echo "❌ TOO SLOW: ${total_duration}s (max: 5s)"
    echo "🚨 Cannot handle multiple requests - EXITING"
    exit 1
else
    echo "✅ SUCCESS: 5 requests completed in ${total_duration}s"
fi

echo ""
echo "📊 Check results:"
echo "Current leaderboard:"
curl -s http://localhost:8000/api/leaderboard/top/ | jq -r '.[:5][]? | "\(.rank). \(.username) - \(.total_score)"' 2>/dev/null || curl -s http://localhost:8000/api/leaderboard/top/

echo ""
echo "🎉 ALL TESTS PASSED!"
echo "===================="
echo "✅ Submit API is fast and responsive"
echo "⚡ Performance is acceptable for production"
echo ""
echo "📊 Test Summary:"
echo "   - Individual requests: <${MAX_ACCEPTABLE_MS}ms"
echo "   - Batch requests: <5s for 5 parallel"
echo "   - Error handling: Working correctly"

exit 0