# ---- Base ----
FROM python:3.11-slim AS base

# Set working directory
WORKDIR /code

# Copy dependency files
COPY requirements.txt requirements.txt

# Install base dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ---- Development Stage ----
FROM base AS dev

# Copy additional data dependencies (if any)
COPY data/requirements-data.txt data/requirements-data.txt
RUN pip install --no-cache-dir -r data/requirements-data.txt

# Copy entire project
COPY . .

# Expose dev ports
EXPOSE 5000 8888

# Default to interactive shell (for manual Flask/Jupyter start)
CMD ["bash"]

# ---- Production Stage ----
FROM base AS prod

# Copy only what's needed for production
COPY app/ app/

# Ensure Waitress is installed (in case not in requirements.txt)
RUN pip install --no-cache-dir waitress

# Cleanup (optional)
RUN rm -rf app/__pycache__ requirements.txt

# Expose prod port
EXPOSE 8000

# Run the Flask app via Waitress
CMD ["waitress-serve", "--listen=0.0.0.0:8000", "app.app:app"]
