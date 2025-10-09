# --- Builder stage ---
FROM python:3.11-slim AS builder


# Install build-time dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
build-essential \
ca-certificates \
&& rm -rf /var/lib/apt/lists/*


WORKDIR /src


# Copy only the files needed to install dependencies
COPY requirements.txt ./


# Install dependencies into /install to copy them later
RUN pip install --upgrade pip && \
pip install --prefix=/install -r requirements.txt --no-cache-dir


# --- Final stage ---
FROM python:3.11-slim


# Create a non-root user for better security
RUN useradd --create-home appuser
WORKDIR /home/appuser


# Copy installed site-packages from the builder
COPY --from=builder /install /usr/local


# Copy app code last (so changes here do not invalidate installed deps layer)
COPY app.py ./


# Expose the listen port
ENV PORT=5000
EXPOSE ${PORT}


# Ensure we run as non-root
USER appuser


# Healthcheck using python's stdlib so we don't need curl/wget in the final image
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
CMD python -c "import urllib.request,sys; \
try:\n r=urllib.request.urlopen('http://127.0.0.1:'+str(${PORT})+'/health', timeout=4); \
data=r.read(); \
if r.getcode()!=200: sys.exit(1)\nexcept Exception as e:\n sys.exit(1)"


# Use gunicorn for production-like entrypoint
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app", "--workers", "2"]