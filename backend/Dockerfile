# Use Python 3.11 slim image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        build-essential \
        libpq-dev \
        netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files first
COPY requirements.txt manage.py /app/
COPY gaming_leaderboard/ /app/gaming_leaderboard/
COPY leaderboard/ /app/leaderboard/

# Copy entrypoint scripts
COPY entrypoint.sh /app/entrypoint.sh
COPY celery-worker-entrypoint.sh /app/celery-worker-entrypoint.sh
COPY celery-beat-entrypoint.sh /app/celery-beat-entrypoint.sh

# Make scripts executable
RUN chmod +x /app/entrypoint.sh && \
    chmod +x /app/celery-worker-entrypoint.sh && \
    chmod +x /app/celery-beat-entrypoint.sh

# Create staticfiles directory
RUN mkdir -p /app/staticfiles

# Expose port
EXPOSE 8000

# Use entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]