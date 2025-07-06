# How to Submit Scores - Gaming Leaderboard

## 🎯 Score Submission Guide

### Method 1: Using curl (Command Line)

#### Basic Score Submission
```bash
curl -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 1500}'
```

#### Example with Different Users and Scores
```bash
# Submit score for user 1
curl -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 2500}'

# Submit score for user 2
curl -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2, "score": 1800}'

# Submit score for user 3
curl -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 3, "score": 3200}'
```

#### Expected Response
```json
{
  "message": "Score submitted successfully",
  "total_score": 4000
}
```

### Method 2: Using Python requests

```python
import requests
import json

# API endpoint
url = "http://localhost:8000/api/leaderboard/submit/"

# Score data
data = {
    "user_id": 1,
    "score": 1500
}

# Make the request
response = requests.post(
    url, 
    headers={"Content-Type": "application/json"},
    data=json.dumps(data)
)

if response.status_code == 201:
    result = response.json()
    print(f"Success! New total score: {result['total_score']}")
else:
    print(f"Error: {response.text}")
```

### Method 3: Using JavaScript/Node.js

```javascript
const axios = require('axios');

async function submitScore(userId, score) {
    try {
        const response = await axios.post('http://localhost:8000/api/leaderboard/submit/', {
            user_id: userId,
            score: score
        });
        
        console.log('Score submitted successfully!');
        console.log('New total score:', response.data.total_score);
        return response.data;
    } catch (error) {
        console.error('Error submitting score:', error.response?.data || error.message);
    }
}

// Usage
submitScore(1, 1500);
```

### Method 4: Using the Frontend (Browser)

1. **Open the application**: http://localhost:3000
2. **View current leaderboard** - You'll see the top players
3. **Check player rank** - Use the "Check Player Rank" section to verify current standings

*Note: Direct score submission via frontend UI is not implemented yet. Scores must be submitted via API.*

## 📊 Score Submission Details

### Required Fields
- **user_id** (integer): The ID of the user submitting the score
- **score** (integer): The score value (must be >= 0)

### Optional Fields
- **game_mode** (string): Defaults to "classic" if not provided

### Response Codes
- **201 Created**: Score submitted successfully
- **400 Bad Request**: Invalid data (missing fields, invalid user_id, negative score)
- **404 Not Found**: User doesn't exist
- **500 Internal Server Error**: Server error

## 🛠️ Setup Test Users

Before submitting scores, make sure you have users in the system:

```bash
# Create test users via Django shell
docker compose exec backend python manage.py shell
```

```python
from leaderboard.models import User

# Create test users
user1 = User.objects.create_user(username='player1', password='test123')
user2 = User.objects.create_user(username='player2', password='test123')
user3 = User.objects.create_user(username='player3', password='test123')

print(f"Created users with IDs: {user1.id}, {user2.id}, {user3.id}")
```

Or use the automated setup script:
```bash
./setup.sh
```

## 🎮 Complete Example Workflow

```bash
# 1. Start the system
docker compose up -d

# 2. Wait for services to be ready
sleep 30

# 3. Submit multiple scores for different users
curl -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 1500}'

curl -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2, "score": 1200}'

curl -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 800}'

# 4. Check the leaderboard
curl http://localhost:8000/api/leaderboard/top/

# 5. Check specific user rank
curl http://localhost:8000/api/leaderboard/rank/1/
```

## 🔍 Verify Score Submission

### Check Leaderboard
```bash
curl http://localhost:8000/api/leaderboard/top/
```

### Check User Rank
```bash
curl http://localhost:8000/api/leaderboard/rank/1/
```

### View in Browser
- **Frontend**: http://localhost:3000
- **Admin Panel**: http://localhost:8000/admin (login: admin/admin123)

## ❌ Common Issues

### User Not Found (404)
```json
{"error": "User not found"}
```
**Solution**: Create the user first or use an existing user ID.

### Invalid Score (400)
```json
{"user_id": ["This field is required."], "score": ["Ensure this value is greater than or equal to 0."]}
```
**Solution**: Provide valid user_id and non-negative score.

### Connection Refused
```bash
curl: (7) Failed to connect to localhost port 8000: Connection refused
```
**Solution**: Make sure the backend is running with `docker compose ps backend`.

## 🚀 Advanced Usage

### Batch Score Submission Script
```bash
#!/bin/bash
# batch_submit.sh

USER_ID=$1
NUM_SCORES=$2

if [ -z "$USER_ID" ] || [ -z "$NUM_SCORES" ]; then
    echo "Usage: ./batch_submit.sh <user_id> <number_of_scores>"
    exit 1
fi

for i in $(seq 1 $NUM_SCORES); do
    SCORE=$((RANDOM % 1000 + 100))
    echo "Submitting score $SCORE for user $USER_ID (submission $i/$NUM_SCORES)"
    
    curl -X POST http://localhost:8000/api/leaderboard/submit/ \
      -H "Content-Type: application/json" \
      -d "{\"user_id\": $USER_ID, \"score\": $SCORE}" \
      -s > /dev/null
    
    sleep 0.5
done

echo "Batch submission completed!"
```

### Game Integration Example
```python
class GameSession:
    def __init__(self, user_id):
        self.user_id = user_id
        self.score = 0
        
    def add_points(self, points):
        self.score += points
        
    def submit_final_score(self):
        """Submit score when game ends"""
        url = "http://localhost:8000/api/leaderboard/submit/"
        data = {
            "user_id": self.user_id,
            "score": self.score
        }
        
        try:
            response = requests.post(url, json=data)
            if response.status_code == 201:
                result = response.json()
                print(f"Score submitted! Total: {result['total_score']}")
                return True
        except Exception as e:
            print(f"Failed to submit score: {e}")
            return False

# Usage in game
game = GameSession(user_id=1)
game.add_points(500)
game.add_points(300)
game.submit_final_score()  # Submits 800 points
```