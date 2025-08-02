# Multi-stage build for Railway deployment
FROM node:18-alpine AS frontend-builder

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
COPY --from=frontend-builder /app/frontend/build/ ./web/

# Copy configuration files
COPY production.xml ./
COPY schema/ ./schema/

# Create necessary directories
RUN mkdir -p ./logs ./data ./media

# Set permissions
RUN chmod +x ./target/*.jar

# Create startup script
RUN echo '#!/bin/bash' > start.sh && \
    echo 'export PORT=${PORT:-8080}' >> start.sh && \
    echo 'java ${JAVA_OPTS} -jar target/*.jar production.xml' >> start.sh && \
    chmod +x start.sh

# Expose port (Railway will set PORT environment variable)
EXPOSE ${PORT:-8080}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/api/server || exit 1

CMD ["./start.sh"] 