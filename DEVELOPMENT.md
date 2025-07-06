# Gaming Leaderboard - Development Guide

## Quick Commands

### Docker Operations
```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f celery_worker

# Stop all services
docker compose down

# Rebuild specific service
docker compose build backend
docker compose up backend

# Clean up everything
docker compose down -v --rmi all
```

### Django Operations
```bash
# Run migrations
docker compose exec backend python manage.py migrate

# Create superuser
docker compose exec backend python manage.py createsuperuser

# Django shell
docker compose exec backend python manage.py shell

# Run tests
docker compose exec backend python manage.py test

# Collect static files
docker compose exec backend python manage.py collectstatic
```

### Database Operations
```bash
# Access PostgreSQL
docker compose exec db psql -U postgres -d gaming_leaderboard

# Reset database
docker compose down
docker volume rm gaming-leaderboard_postgres_data
docker compose up -d
```

### Redis Operations
```bash
# Access Redis CLI
docker compose exec redis redis-cli

# Clear cache
docker compose exec redis redis-cli FLUSHALL
```

### Frontend Operations
```bash
# Install new packages
docker compose exec frontend npm install package-name

# Run tests
docker compose exec frontend npm test

# Build for production
docker compose exec frontend npm run build
```

## API Testing with curl

### Submit Score
```bash
curl -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 1500}'
```

### Get Top Leaderboard
```bash
curl http://localhost:8000/api/leaderboard/top/
```

### Get User Rank
```bash
curl http://localhost:8000/api/leaderboard/rank/1/
```

## Development Workflow

1. Make code changes
2. Services auto-reload (Django dev server, React dev server)
3. Test changes via frontend or API
4. Run tests: `docker compose exec backend python manage.py test`
5. Commit changes

## Troubleshooting

### Port Already in Use
```bash
# Find process using port
lsof -i :8000
lsof -i :3000

# Kill process
kill -9 <PID>
```

### Database Connection Issues
```bash
# Check if PostgreSQL is running
docker compose ps db

# Restart database
docker compose restart db
```

### Redis Connection Issues
```bash
# Check if Redis is running
docker compose ps redis

# Restart Redis
docker compose restart redis
```

### Frontend Build Issues
```bash
# Clear node_modules and reinstall
docker compose exec frontend rm -rf node_modules
docker compose exec frontend npm install
```