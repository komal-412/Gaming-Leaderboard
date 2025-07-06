#!/bin/bash

# Gaming Leaderboard Setup Script

echo "🎮 Setting up Gaming Leaderboard System..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker &> /dev/null || ! docker compose version &> /dev/null; then
    echo "❌ Docker or Docker Compose is not installed. Please install Docker with Compose plugin first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Build and start all services
echo "🔨 Building and starting all services..."
docker compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 60

# Check if backend is ready
echo "� Checking backend status..."
for i in {1..30}; do
  if curl -s http://localhost:8000/api/leaderboard/top/ > /dev/null 2>&1; then
    echo "✅ Backend is ready!"
    break
  fi
  echo "Waiting for backend... ($i/30)"
  sleep 2
done

# Create superuser (optional)
echo "👤 Would you like to create a Django superuser? (y/n)"
read -r create_superuser
if [[ $create_superuser == "y" || $create_superuser == "Y" ]]; then
    echo "Note: A default admin user (admin/admin123) has already been created."
    echo "You can create an additional superuser:"
    docker compose exec backend python manage.py createsuperuser
fi

# Create test users
echo "🎯 Creating test users..."
docker compose exec -T backend python manage.py shell << 'EOF'
from leaderboard.models import User
try:
    User.objects.create_user(username='player1', password='testpass123')
    User.objects.create_user(username='player2', password='testpass123')
    User.objects.create_user(username='player3', password='testpass123')
    print("Test users created successfully!")
except Exception as e:
    print(f"Users might already exist: {e}")
EOF

# Submit some test scores
echo "🏆 Adding test scores..."
curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 1500}' > /dev/null

curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2, "score": 1200}' > /dev/null

curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 3, "score": 1800}' > /dev/null

curl -s -X POST http://localhost:8000/api/leaderboard/submit/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "score": 2000}' > /dev/null

echo "🎉 Setup completed successfully!"
echo ""
echo "🌐 Application URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000"
echo "   Admin Panel: http://localhost:8000/admin"
echo ""
echo "📊 API Endpoints:"
echo "   GET  /api/leaderboard/top/"
echo "   POST /api/leaderboard/submit/"
echo "   GET  /api/leaderboard/rank/{user_id}/"
echo ""
echo "🛠️  Useful commands:"
echo "   View logs: docker compose logs -f"
echo "   Stop services: docker compose down"
echo "   Restart services: docker compose restart"