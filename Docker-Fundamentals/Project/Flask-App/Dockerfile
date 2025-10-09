# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory in the container
WORKDIR /app

# Copy requirements file first (for better Docker layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY app.py .

# Expose the port the app runs on
EXPOSE 5000

# Create a non-root user for security
RUN adduser --disabled-password --gecos '' rchandran && \
    chown -R rchandran:rchandran /app
USER rchandran

# Command to run the application
CMD ["python", "app.py"]