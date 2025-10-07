# Docker Hands-On Assignment
**Everything You Need To Know About Docker**

## Objective
Master Docker fundamentals by building, running, and managing containers. Learn Docker networking, volumes, and image creation through hands-on practice.

## Prerequisites
- Docker installed on your machine (Docker Desktop for Mac/Windows or Docker Engine for Linux)
- Basic command line knowledge
- Text editor of your choice

---

## Part 1: Docker Basics (30 minutes)

### Task 1.1: Running Your First Containers
1. **Pull and run basic containers:**
   ```bash
   docker run -d -t --name my-alpine alpine
   docker run -d -t --name my-busybox busybox
   ```

2. **List all containers:**
   ```bash
   docker ps
   docker ps -a
   ```

3. **Check downloaded images:**
   ```bash
   docker image ls
   ```

**Questions to Answer:**
- What's the difference between `docker ps` and `docker ps -a`?
- Why are Alpine and BusyBox images so small?

### Task 1.2: Container Interaction
1. **Execute commands in running containers:**
   ```bash
   docker exec -t my-alpine ls /
   docker exec -t my-busybox ps aux
   ```

2. **Open interactive shell sessions:**
   ```bash
   docker exec -it my-alpine sh
   # Inside container: run `whoami`, `pwd`, `ls -la`
   # Type `exit` to leave
   ```

3. **Container lifecycle management:**
   ```bash
   docker stop my-alpine
   docker start my-alpine
   docker rm -f my-busybox
   ```

**Deliverable:** Take screenshots of your container interactions and note the differences between Alpine and BusyBox.

---

## Part 2: Docker Networking (45 minutes)

### Task 2.1: Default Bridge Network
1. **Run Nginx container:**
   ```bash
   docker run -d --name nginx-default nginx:latest
   ```

2. **Inspect the container:**
   ```bash
   docker inspect nginx-default
   # Look for NetworkSettings section
   ```

3. **Test connectivity:**
   ```bash
   docker exec -it nginx-default curl localhost:80
   # Try accessing from host (this should fail):
   curl localhost:80
   ```

### Task 2.2: Port Forwarding
1. **Run Nginx with port mapping:**
   ```bash
   docker rm -f nginx-default
   docker run -d -p 8080:80 --name nginx-exposed nginx:latest
   ```

2. **Test access:**
   ```bash
   # From your host machine:
   curl localhost:8080
   # Or open browser to http://localhost:8080
   ```

### Task 2.3: Custom Bridge Network
1. **Create custom network:**
   ```bash
   docker network create my-network
   docker network ls
   ```

2. **Run containers in custom network:**
   ```bash
   docker run -d --network my-network --name web-server nginx:latest
   docker run -it --network my-network --name client alpine sh
   ```

3. **Test name resolution:**
   ```bash
   # Inside the Alpine container:
   ping web-server
   wget -qO- http://web-server
   ```

**Questions to Answer:**
- Why can containers ping each other by name in custom networks but not in the default bridge?
- What happens when you try to access the web server from your host machine in the custom network?

---

## Part 3: Docker Volumes (30 minutes)

### Task 3.1: Bind Mounts
1. **Create a directory on your host:**
   ```bash
   mkdir shared-logs
   ```

2. **Run containers with bind mount:**
   ```bash
   docker run -d -v $(pwd)/shared-logs:/app/logs --name logger1 alpine tail -f /dev/null
   docker run -d -v $(pwd)/shared-logs:/app/logs --name logger2 busybox tail -f /dev/null
   ```

3. **Create files from containers:**
   ```bash
   docker exec logger1 sh -c "echo 'Log from container 1' > /app/logs/container1.log"
   docker exec logger2 sh -c "echo 'Log from container 2' > /app/logs/container2.log"
   ```

4. **Verify file sharing:**
   ```bash
   # Check from host:
   ls shared-logs/
   cat shared-logs/*.log
   
   # Check from containers:
   docker exec logger1 ls /app/logs/
   docker exec logger2 ls /app/logs/
   ```

### Task 3.2: Docker Volumes
1. **Create and use Docker volume:**
   ```bash
   docker volume create app-data
   docker volume ls
   docker volume inspect app-data
   ```

2. **Mount volume in containers:**
   ```bash
   docker run -d --mount source=app-data,target=/data --name data1 alpine tail -f /dev/null
   docker run -d --mount source=app-data,target=/data --name data2 nginx:latest
   ```

3. **Test data persistence:**
   ```bash
   docker exec data1 sh -c "echo 'Persistent data' > /data/test.txt"
   docker exec data2 cat /data/test.txt
   ```

**Deliverable:** Explain the difference between bind mounts and Docker volumes. When would you use each?

---

## Part 4: Building Docker Images (60 minutes)

### Task 4.1: Create a Flask Application
1. **Create project directory:**
   ```bash
   mkdir flask-docker-app
   cd flask-docker-app
   ```

2. **Create application files:**

   **app.py:**
   ```python
   from flask import Flask, jsonify
   import os
   
   app = Flask(__name__)
   
   @app.route('/')
   def hello():
       return jsonify({
           "message": "Hello from Docker!",
           "container_id": os.environ.get('HOSTNAME', 'unknown')
       })
   
   @app.route('/health')
   def health():
       return jsonify({"status": "healthy"})
   
   if __name__ == '__main__':
       app.run(debug=True, host='0.0.0.0', port=5000)
   ```

   **requirements.txt:**
   ```
   Flask==2.3.3
   ```

   **Dockerfile:**
   ```dockerfile
   FROM python:3.11-slim
   
   WORKDIR /app
   
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   
   COPY app.py .
   
   EXPOSE 5000
   
   CMD ["python", "app.py"]
   ```

### Task 4.2: Build and Test Image
1. **Build the image:**
   ```bash
   docker build -t my-flask-app:v1.0 .
   ```

2. **Run container:**
   ```bash
   docker run -d -p 5000:5000 --name flask-app my-flask-app:v1.0
   ```

3. **Test the application:**
   ```bash
   curl localhost:5000
   curl localhost:5000/health
   ```

### Task 4.3: Multi-container Application
1. **Create docker-compose.yml:**
   ```yaml
   version: '3.8'
   services:
     web:
       build: .
       ports:
         - "5000:5000"
       volumes:
         - app-logs:/app/logs
       networks:
         - app-network
     
     redis:
       image: redis:alpine
       networks:
         - app-network
   
   volumes:
     app-logs:
   
   networks:
     app-network:
   ```

2. **Run with docker-compose:**
   ```bash
   docker-compose up -d
   docker-compose ps
   ```

---

## Part 5: Image Registry (30 minutes)

### Task 5.1: Push to Docker Hub
1. **Create Docker Hub account** (if you don't have one)

2. **Login to Docker Hub:**
   ```bash
   docker login
   ```

3. **Tag and push image:**
   ```bash
   docker tag my-flask-app:v1.0 yourusername/flask-demo:v1.0
   docker push yourusername/flask-demo:v1.0
   ```

4. **Test pulling image:**
   ```bash
   docker rmi my-flask-app:v1.0 yourusername/flask-demo:v1.0
   docker run -d -p 5001:5000 yourusername/flask-demo:v1.0
   ```

---

## Assignment Deliverables

### 1. Lab Report (Submit as PDF)
Create a document containing:
- Screenshots of each major task completion
- Answers to all questions posed in the tasks
- Docker commands used and their outputs
- Explanation of networking concepts learned

### 2. Code Repository
Create a Git repository with:
- Flask application code
- Dockerfile
- docker-compose.yml
- README.md with setup instructions

### 3. Reflection Questions (Answer in your report)
1. **Container vs VM:** Explain the key differences between Docker containers and virtual machines.

2. **Networking:** Why do containers in custom bridge networks have DNS resolution while default bridge network containers don't?

3. **Data Persistence:** When would you choose bind mounts over Docker volumes and vice versa?

4. **Image Optimization:** What strategies could you use to reduce Docker image size?

5. **Security:** What are three security best practices when building Docker images?

6. **Production Readiness:** What additional considerations would you need for running containers in production?

---

## Bonus Challenges

### Challenge 1: Multi-stage Build
Create a Dockerfile using multi-stage builds to reduce the final image size.

### Challenge 2: Health Checks
Add health checks to your containers and demonstrate how they work.

### Challenge 3: Container Monitoring
Set up basic monitoring for your containers using docker stats and logging.

### Challenge 4: Environment Variables
Modify your Flask app to use environment variables for configuration and demonstrate different ways to pass them to containers.

---

## Evaluation Criteria

**Basic Tasks (70 points):**
- Container management and interaction
- Networking configuration and testing
- Volume usage and data persistence
- Image building and running

**Documentation (20 points):**
- Clear explanations of concepts
- Well-documented commands and outputs
- Thoughtful answers to reflection questions

**Code Quality (10 points):**
- Clean, working application code
- Proper Dockerfile best practices
- Clear repository organization

**Total: 100 points**

**Time Estimate:** 3-4 hours

---

## Resources
- [Official Docker Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Submission
Submit your lab report PDF and provide the link to your Git repository by the due date specified by your instructor.