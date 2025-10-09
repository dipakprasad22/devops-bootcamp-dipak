#!/usr/bin/env bash
set -e

# Build the image
docker-compose build --no-cache

# Start the service in background
docker-compose up -d

# Show container status and health
echo "Container status (including health):"
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

# Stream logs (new terminal recommended)
echo "To stream logs: docker logs -f flask-demo-web"

# Show live resource usage (open in another terminal):
echo "Run 'docker stats' in another terminal to see live CPU / MEM usage of containers."

# Optional: show cAdvisor UI
echo "If cadvisor is deployed, browse http://localhost:8080"