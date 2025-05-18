FROM python:3.9-slim-bullseye

# Add non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Update and install security patches
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirement.txt .
RUN pip install --no-cache-dir -r requirement.txt

# Download NLTK data
RUN python -c "import nltk; nltk.download('punkt'); nltk.download('punkt_tab'); nltk.download('averaged_perceptron_tagger')"

# Copy the rest of the application (venv will be excluded by .dockerignore)
COPY . .

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV OMP_NUM_THREADS=1
ENV KMP_DUPLICATE_LIB_OK=TRUE

# Create models directory
RUN mkdir -p /app/models

# Make entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Set proper permissions (more selective to avoid permission errors)
RUN find /app -type f -not -path "*/\.*" -exec chown appuser:appuser {} \; || true
RUN find /app -type d -not -path "*/\.*" -exec chown appuser:appuser {} \; || true

# Switch to non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 3000

# Use entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]
