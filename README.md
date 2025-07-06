# Gaming Leaderboard System

A complete end-to-end gaming leaderboard system built with Django REST Framework backend and React.js frontend.

## 🏗️ Architecture

- **Backend**: Django + Django REST Framework + PostgreSQL + Redis + Celery
- **Frontend**: React.js + Axios
- **Containerization**: Docker + Docker Compose

## 🚀 Features

### Backend APIs
- `POST /api/leaderboard/submit` - Submit new game scores
- `GET /api/leaderboard/top` - Get top 10 players (cached for 5 seconds)
- `GET /api/leaderboard/rank/{user_id}` - Get individual player rank (cached)

### Frontend Components
- **Leaderboard**: Real-time top 10 players display (auto-refresh every 5s)
- **PlayerRank**: Search for individual player rankings

### Performance Features
- Redis caching for leaderboard data
- Database indexing on critical fields
- Atomic transactions for score submissions
- Periodic rank recomputation via Celery tasks

## 📋 Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local frontend development)
- Python 3.11+ (for local backend development)

## 🛠️ Setup & Installation

### Quick Start with Docker

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Gaming Leaderboard
   ```

2. **Start all services**
   ```bash
   docker compose up --build
   ```

3. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - Admin Panel: http://localhost:8000/admin

### Initial Setup

4. **Create Django superuser** (in a new terminal)
   ```bash
   docker compose exec backend python manage.py createsuperuser
   ```

5. **Create test users** (optional)
   ```bash
   docker compose exec backend python manage.py shell
   ```
   ```python
   from leaderboard.models import User
   User.objects.create_user(username='player1', password='testpass123')
   User.objects.create_user(username='player2', password='testpass123')
   User.objects.create_user(username='player3', password='testpass123')
   ```

## 🎮 Usage

### Submit Scores via API

```bash
# Submit a score for user ID 1
curl -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 1500}'

# Quick demo with multiple scores
chmod +x demo_scores.sh
./demo_scores.sh
```

For detailed score submission examples, see [SCORE_SUBMISSION.md](SCORE_SUBMISSION.md).

### Frontend Usage

1. Open http://localhost:3000
2. View the real-time leaderboard (updates every 5 seconds)
3. Use the "Check Player Rank" section to search for specific user rankings

## 🏗️ Local Development

### Backend Development

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set environment variables**
   ```bash
   export DEBUG=True
   export SECRET_KEY=your-secret-key
   export DB_NAME=gaming_leaderboard
   export DB_USER=postgres
   export DB_PASSWORD=postgres
   export DB_HOST=localhost
   export DB_PORT=5432
   export REDIS_HOST=localhost
   export REDIS_PORT=6379
   ```

5. **Run migrations**
   ```bash
   python manage.py migrate
   ```

6. **Start development server**
   ```bash
   python manage.py runserver
   ```

### Frontend Development

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start development server**
   ```bash
   npm start
   ```

### Celery Workers

Start Celery worker and beat scheduler:

```bash
# Worker
celery -A gaming_leaderboard worker --loglevel=info

# Beat scheduler (in separate terminal)
celery -A gaming_leaderboard beat --loglevel=info
```

## 🐳 Docker Commands

```bash
# Build and start all services
docker compose up --build

# Start services in background
docker compose up -d

# View logs
docker compose logs -f

# Stop all services
docker compose down

# Rebuild specific service
docker compose build backend
docker compose up backend

# Run Django commands
docker compose exec backend python manage.py migrate
docker compose exec backend python manage.py collectstatic
docker compose exec backend python manage.py createsuperuser

# Access database
docker compose exec db psql -U postgres -d gaming_leaderboard
```

## 📊 Database Schema

### Models

1. **User**
   - id (Primary Key)
   - username (Unique)
   - join_date (DateTime)

2. **GameSession**
   - id (Primary Key)
   - user (Foreign Key to User)
   - score (Integer)
   - game_mode (String)
   - timestamp (DateTime)

3. **Leaderboard**
   - id (Primary Key)
   - user (OneToOne to User)
   - total_score (Integer)
   - rank (Integer)

### Indexes
- GameSession.user_id
- Leaderboard.total_score
- Leaderboard.rank

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| DEBUG | True | Django debug mode |
| SECRET_KEY | - | Django secret key |
| DB_NAME | gaming_leaderboard | Database name |
| DB_USER | postgres | Database user |
| DB_PASSWORD | postgres | Database password |
| DB_HOST | localhost | Database host |
| DB_PORT | 5432 | Database port |
| REDIS_HOST | localhost | Redis host |
| REDIS_PORT | 6379 | Redis port |

### Caching Strategy

- **Leaderboard Top 10**: Cached for 5 seconds
- **Individual Ranks**: Cached for 30 seconds
- **Cache Keys**: 
  - `leaderboard_top_10`
  - `user_rank_{user_id}`

### Celery Tasks

- **recompute_all_ranks**: Runs every 5 minutes to ensure rank consistency

## 🚀 Production Deployment

### Security Considerations

1. Change `SECRET_KEY` to a secure random string
2. Set `DEBUG=False`
3. Configure proper database credentials
4. Use environment variables for sensitive data
5. Set up proper CORS origins
6. Use HTTPS in production

### Scaling Considerations

1. **Database**: Consider read replicas for heavy read workloads
2. **Redis**: Use Redis Cluster for high availability
3. **Celery**: Scale workers based on task load
4. **Load Balancing**: Use nginx for static files and load balancing

## 🧪 Testing

```bash
# Run Django tests
docker compose exec backend python manage.py test

# Run React tests
docker compose exec frontend npm test
```

## 📝 API Documentation

### Submit Score
```
POST /api/leaderboard/submit/
Content-Type: application/json

{
  "user_id": 1,
  "score": 1500
}

Response: 201 Created
{
  "message": "Score submitted successfully",
  "total_score": 3500
}
```

### Get Top Leaderboard
```
GET /api/leaderboard/top/

Response: 200 OK
[
  {
    "user": 1,
    "username": "player1",
    "total_score": 3500,
    "rank": 1
  },
  ...
]
```

### Get User Rank
```
GET /api/leaderboard/rank/1/

Response: 200 OK
{
  "user_id": 1,
  "rank": 1
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🎯 Future Enhancements

- [ ] Real-time updates using WebSockets
- [ ] Multiple game modes support
- [ ] Historical score tracking
- [ ] Player profiles and achievements
- [ ] Tournament system
- [ ] Mobile app
- [ ] Social features (friends, chat)
- [ ] Advanced analytics and statistics