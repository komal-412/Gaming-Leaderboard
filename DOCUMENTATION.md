# Gaming Leaderboard - Complete Documentation

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Frontend Features](#frontend-features)
- [Available Scripts](#available-scripts)
- [Development Guide](#development-guide)
- [Troubleshooting](#troubleshooting)
- [Performance Optimizations](#performance-optimizations)

## 🎯 Overview

The Gaming Leaderboard is a full-stack web application built with React (frontend) and Django (backend) that allows players to submit game scores and view real-time leaderboards. The system is optimized for high performance and includes comprehensive testing and troubleshooting tools.

### Tech Stack
- **Frontend**: React.js with modern hooks
- **Backend**: Django REST Framework
- **Database**: PostgreSQL
- **Cache**: Redis
- **Containerization**: Docker & Docker Compose

## ✨ Features

### Core Features
- ✅ **Real-time Leaderboard** - View top 10 players with live updates
- ✅ **Score Submission** - Submit scores via web interface or API
- ✅ **Multiple Game Modes** - Support for Classic, Solo, Team, Ranked, Casual
- ✅ **User Management** - Automatic user creation and score tracking
- ✅ **Performance Optimized** - Sub-second API responses
- ✅ **Responsive UI** - Works on desktop and mobile devices

### Advanced Features
- 🏆 **Medal System** - Gold, Silver, Bronze medals for top 3
- 📊 **Score Aggregation** - Total scores across all game sessions
- 🎮 **Game Mode Tracking** - Separate tracking for different game types
- 🔄 **Auto-refresh** - Real-time leaderboard updates
- ⚡ **Caching** - Redis caching for improved performance
- 🧪 **Testing Suite** - Comprehensive API testing tools

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Ports 3000, 8000, 5432, 6379 available

### Setup & Installation
```bash
# 1. Clone and navigate to project
cd "Gaming Leaderboard"

# 2. Run complete setup
./setup.sh

# 3. Add sample data
./quick_test.sh

# 4. Visit the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
```

### First Use
1. Open http://localhost:3000 in your browser
2. Use the "Submit New Score" form to add your first score
3. View the leaderboard update in real-time
4. Try different game modes and watch scores accumulate

## 📁 Project Structure

```
Gaming Leaderboard/
├── 📄 README.md                  # Main documentation
├── 📄 DOCUMENTATION.md           # This comprehensive guide
├── 📄 DEVELOPMENT.md             # Development commands
├── 📄 SCORE_SUBMISSION.md        # API usage guide
├── 📄 docker-compose.yml         # Container orchestration
├── 📄 .env.example               # Environment variables template
│
├── 📁 backend/                   # Django Backend
│   ├── 📁 gaming_leaderboard/    # Django project settings
│   ├── 📁 leaderboard/           # Main Django app
│   │   ├── models.py            # Database models
│   │   ├── views.py             # API endpoints (optimized)
│   │   ├── urls.py              # URL routing
│   │   └── serializers.py       # API serializers
│   ├── requirements.txt         # Python dependencies
│   ├── Dockerfile              # Backend container config
│   └── manage.py               # Django management
│
├── 📁 frontend/                  # React Frontend
│   ├── 📁 src/
│   │   ├── App.js              # Main component (with score submission)
│   │   ├── App.css             # Enhanced styling
│   │   └── index.js            # React entry point
│   ├── package.json            # Node.js dependencies
│   ├── Dockerfile             # Frontend container config
│   └── public/                # Static assets
│
└── 🔧 Essential Scripts/         # Management scripts
    ├── setup.sh                # Complete setup & initialization
    ├── clean_restart.sh        # Clean restart with volume options
    ├── troubleshoot.sh         # Comprehensive diagnostics
    ├── test_submit_api.sh      # Submit API testing (with timeouts)
    ├── test_api.sh             # General API endpoint testing
    ├── demo_scores.sh          # Add demo/sample data
    ├── quick_test.sh           # Quick system verification + data
    ├── manual_populate.sh      # Manual data creation
    └── populate_large_data.sh  # Large dataset population
```

## 🔌 API Documentation

### Base URL
- **Development**: `http://localhost:8000/api/`

### Endpoints

#### 1. Get Top Leaderboard
```http
GET /api/leaderboard/top/
```
**Response:**
```json
[
  {
    "rank": 1,
    "user_id": 1,
    "username": "alice",
    "total_score": 2500
  }
]
```

#### 2. Get User Rank
```http
GET /api/leaderboard/rank/{user_id}/
```
**Response:**
```json
{
  "user_id": 1,
  "username": "alice",
  "rank": 1,
  "total_score": 2500
}
```

#### 3. Submit Score
```http
POST /api/leaderboard/submit/
Content-Type: application/json

{
  "user_id": 1,
  "score": 1500,
  "game_mode": "ranked"
}
```
**Response:**
```json
{
  "message": "Success",
  "total_score": 4000
}
```

### API Performance
- **Response Time**: <200ms for single requests
- **Timeout**: 3 seconds maximum
- **Rate Limiting**: None (suitable for gaming applications)
- **Caching**: 60 seconds for leaderboard, 30 seconds for user ranks

## 🎨 Frontend Features

### Score Submission Form
- **Player Name**: Text input with validation
- **Score**: Numeric input (non-negative numbers only)
- **Game Mode**: Dropdown selection (Classic, Solo, Team, Ranked, Casual)
- **Validation**: Real-time form validation with error messages
- **Feedback**: Success/error messages with color coding

### Leaderboard Display
- **Top 10 Players**: Real-time leaderboard with auto-refresh
- **Medal System**: 🥇🥈🥉 for top 3 players
- **Special Styling**: Gold, silver, bronze highlighting
- **Responsive Design**: Works on all screen sizes
- **Loading States**: Visual feedback during data fetching

### User Experience
- **Auto-refresh**: Leaderboard updates after score submission
- **Instant Feedback**: Immediate success/error messages
- **Keyboard Friendly**: Full keyboard navigation support
- **Mobile Optimized**: Touch-friendly interface

## 🛠️ Available Scripts

### Setup & Management
```bash
./setup.sh                    # Complete setup with user creation
./clean_restart.sh            # Clean restart (option to remove data)
./troubleshoot.sh             # Comprehensive system diagnostics
```

### Data Management
```bash
./quick_test.sh               # Add sample users and scores
./demo_scores.sh              # Add demo data for presentation
./manual_populate.sh          # Interactive data creation
./populate_large_data.sh      # Large dataset (1K-100K users)
```

### Testing & Validation
```bash
./test_submit_api.sh          # Test submit API with timeouts
./test_api.sh                 # Test all API endpoints
```

### Docker Commands
```bash
docker compose up -d          # Start all services
docker compose down           # Stop all services
docker compose restart       # Restart all services
docker compose logs backend  # View backend logs
docker compose ps            # Check service status
```

## 💻 Development Guide

### Local Development Setup
1. **Clone the repository**
2. **Run setup**: `./setup.sh`
3. **Access services**:
   - Frontend: http://localhost:3000
   - Backend: http://localhost:8000
   - Admin Panel: http://localhost:8000/admin (admin/admin123)

### Making Changes

#### Frontend Changes
```bash
# Frontend files are in frontend/src/
# Edit App.js or App.css
# Changes are hot-reloaded automatically
docker compose logs frontend  # Check for errors
```

#### Backend Changes
```bash
# Backend files are in backend/leaderboard/
# Edit views.py, models.py, etc.
docker compose restart backend  # Restart to load changes
./test_submit_api.sh           # Test your changes
```

#### Database Changes
```bash
# After modifying models.py
docker compose exec backend python manage.py makemigrations
docker compose exec backend python manage.py migrate
```

### Performance Testing
```bash
# Test API performance
./test_submit_api.sh

# Test with large dataset
./populate_large_data.sh
# Choose option 2 (Medium - 10K users)
./test_submit_api.sh
```

## 🔧 Troubleshooting

### Common Issues & Solutions

#### Backend Not Responding
```bash
# Check status
docker compose ps

# Check logs
docker compose logs backend

# Restart backend
docker compose restart backend

# Complete reset
./clean_restart.sh
```

#### Frontend Shows 404
```bash
# Check if frontend is running
curl http://localhost:3000

# Restart frontend
docker compose restart frontend

# Check logs
docker compose logs frontend
```

#### Database Connection Issues
```bash
# Check database
docker compose exec db pg_isready -U postgres

# Check database logs
docker compose logs db

# Reset database
./clean_restart.sh  # Choose 'y' to remove data
```

#### Port Conflicts
```bash
# Check what's using ports
sudo lsof -i :3000
sudo lsof -i :8000
sudo lsof -i :5432

# Kill conflicting processes
sudo lsof -ti:3000 | xargs sudo kill -9
```

### Performance Issues

#### Slow API Responses
```bash
# Test API performance
./test_submit_api.sh

# Check if using large dataset
docker compose exec -T db psql -U postgres -d gaming_leaderboard -c "SELECT COUNT(*) FROM leaderboard_leaderboard;"

# If >10K users, that's expected (ranks calculated on-demand)
```

#### High Memory Usage
```bash
# Check container resource usage
docker stats

# Restart services
docker compose restart

# If needed, reduce dataset size
./clean_restart.sh  # Remove large dataset
./quick_test.sh     # Add smaller dataset
```

### Getting Help
1. **Run diagnostics**: `./troubleshoot.sh`
2. **Check logs**: `docker compose logs [service_name]`
3. **Test API**: `./test_submit_api.sh`
4. **Reset everything**: `./clean_restart.sh`

## ⚡ Performance Optimizations

### Backend Optimizations
- **No Real-time Rank Calculation**: Ranks calculated on-demand for large datasets
- **Efficient Database Queries**: Direct user_id usage, minimal joins
- **Atomic Transactions**: Ensure data consistency without locks
- **Smart Caching**: Redis caching with appropriate TTL values
- **Bulk Operations**: Efficient database updates when possible

### Frontend Optimizations
- **Component State Management**: Efficient React state updates
- **Conditional Rendering**: Only render when necessary
- **Debounced API Calls**: Prevent excessive API requests
- **Optimistic Updates**: Show changes immediately, confirm later

### Database Optimizations
- **Indexed Columns**: Primary keys and frequently queried fields
- **Connection Pooling**: Efficient database connections
- **Query Optimization**: Minimal data fetching, aggregation at database level

### Caching Strategy
- **Leaderboard Cache**: 60 seconds TTL
- **User Rank Cache**: 30 seconds TTL
- **Automatic Invalidation**: Clear relevant caches on score submission

## 📊 Monitoring & Analytics

### Health Checks
```bash
# System health
./troubleshoot.sh

# API performance
./test_submit_api.sh

# Database status
docker compose exec -T db psql -U postgres -d gaming_leaderboard -c "SELECT COUNT(*) as total_users FROM leaderboard_user;"
```

### Performance Metrics
- **API Response Time**: Target <200ms
- **Score Submission**: Target <500ms
- **Leaderboard Load**: Target <100ms (cached)
- **Database Queries**: Optimized for <50ms

## 📝 License & Contributing

This project is designed for educational and demonstration purposes. Feel free to use, modify, and extend for your own gaming applications.

### Contributing Guidelines
1. Test all changes with `./test_submit_api.sh`
2. Ensure API responses remain under performance targets
3. Update documentation for new features
4. Follow existing code style and patterns

---

## 🎮 Happy Gaming!

Your Gaming Leaderboard is now ready for high-performance score tracking and real-time leaderboard display. Enjoy building the next great gaming experience!