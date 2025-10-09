# Flask Docker Demo

This demo Flask app showcases Docker best practices in four key areas:

## Challenge 1: Multi-stage Build
We use a multi-stage Dockerfile to build dependencies in a temporary builder image and copy only the needed artifacts to the final image. This keeps the image small and secure.

**File:** `Dockerfile`

## Challenge 2: Health Checks
A `/health` endpoint in the Flask app returns a health status. Docker’s `HEALTHCHECK` directive pings this endpoint periodically to mark the container as `healthy` or `unhealthy`.

**Test it:**  
Run `docker ps` and look for the `STATUS` column showing `(healthy)`.

## Challenge 3: Container Monitoring
Monitor running containers with built-in Docker tools:
- `docker stats` — shows live CPU and memory usage.
- `docker logs flask-demo-web` — displays live logs.

You can optionally use **cAdvisor** (included in `docker-compose.yml`) for visual monitoring at `http://localhost:8080`.

## Challenge 4: Environment Variables
The app reads configuration (like port, debug mode, and secret key) from environment variables.

**Ways to pass environment variables:**
1. Inline with `docker run -e SECRET_KEY=mysecret`  
2. From a file using `--env-file .env`  
3. Via Docker Compose (`.env` and `env_file:` in `docker-compose.yml`)

**Sample environment file (.env):**
```
SECRET_KEY=supersecret_from_env_file
FLASK_DEBUG=false
```

## How to Run

### 1. Clone and build
```bash
git clone <this-repo>
cd flask-docker-demo
docker compose up --build -d
```

### 2. Check health
```bash
docker ps
docker inspect -f '{{.State.Health.Status}}' flask-demo-web
```

### 3. Visit app
Go to [http://localhost:5000](http://localhost:5000) in your browser.

### 4. Monitor
Run `docker stats` or check cAdvisor at [http://localhost:8080](http://localhost:8080).

### 5. In case of issue, try building the image locally without Docker first
```bash
python -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```
---

This simple project demonstrates production-grade Docker practices in a minimal Flask setup.
