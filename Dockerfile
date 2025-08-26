# Build stage
FROM python:3.11-slim as builder

# Set working directory
WORKDIR /app

# Copy requirements file
COPY app/requirements.txt .

# Install dependencies in a virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim as production

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY app/ .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Set environment variables
ENV PATH="/opt/venv/bin:$PATH"
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONPATH=/app

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]