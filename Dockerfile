# Multi-stage build for Railway deployment

# Java build stage
FROM eclipse-temurin:17-jdk-alpine AS backend-builder

# Install gradle
RUN apk add --no-cache gradle

WORKDIR /app
COPY . .
RUN gradle build --no-daemon

# Final runtime stage
FROM eclipse-temurin:17-jre-alpine

# Install necessary packages
RUN apk add --no-cache bash curl

WORKDIR /app

# Copy built JAR and dependencies
COPY --from=backend-builder /app/target/ ./target/

# Copy configuration files
COPY production.xml ./
COPY schema/ ./schema/

# Create necessary directories and basic web content
RUN mkdir -p ./logs ./data ./media ./web && \
    echo '<!DOCTYPE html><html><head><title>Traccar API</title></head><body><h1>Traccar API Server</h1><p>API available at <a href="/api">/api</a></p></body></html>' > ./web/index.html

# Set permissions
RUN chmod +x ./target/*.jar

# Create startup script that maps Railway env vars to Traccar expected names
RUN echo '#!/bin/bash' > start.sh && \
    echo 'set -e' >> start.sh && \
    echo '# Set Traccar environment variables' >> start.sh && \
    echo 'export CONFIG_USE_ENVIRONMENT_VARIABLES=true' >> start.sh && \
    echo 'export WEB_PORT=${PORT:-8080}' >> start.sh && \
    echo 'export DATABASE_USER=${PGUSER}' >> start.sh && \
    echo 'export DATABASE_PASSWORD=${PGPASSWORD}' >> start.sh && \
    echo 'export WEB_ADDRESS=0.0.0.0' >> start.sh && \
    echo 'echo "Starting Traccar on port $WEB_PORT"' >> start.sh && \
    echo 'echo "Database URL: $DATABASE_URL"' >> start.sh && \
    echo 'echo "Database User: $DATABASE_USER"' >> start.sh && \
    echo 'java ${JAVA_OPTS:-"-Xms256m -Xmx512m"} -jar target/*.jar production.xml' >> start.sh && \
    chmod +x start.sh



# Expose port (Railway will set PORT environment variable)
EXPOSE ${PORT:-8080}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/api/server || exit 1

CMD ["./start.sh"] 