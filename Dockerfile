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

# Reasonable JVM defaults; can be overridden via env
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# Expose web API port and GPS protocol ports (T55=5005, H02=5013)
EXPOSE ${PORT:-8080}
EXPOSE 5005 5013

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/api/server || exit 1

# Run server directly; expects env vars like WEB_PORT/WEB_ADDRESS, DATABASE_URL, DATABASE_USER, DATABASE_PASSWORD
CMD ["sh", "-lc", "java $JAVA_OPTS -jar target/*.jar production.xml"] 