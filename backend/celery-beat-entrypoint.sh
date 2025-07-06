#!/bin/bash
set -e

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
while ! nc -z backend 8000; do
  sleep 2
done
echo "Backend is ready!"

# Start Celery beat
echo "Starting Celery beat..."
exec celery -A gaming_leaderboard beat --loglevel=info