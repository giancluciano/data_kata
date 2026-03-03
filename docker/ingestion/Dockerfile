# ─── Stage 1: Build ──────────────────────────────────────────────────────────
FROM sbtscala/scala-sbt:eclipse-temurin-24.0.1_9_1.12.5_3.8.2 AS builder

WORKDIR /build

# Copy SBT project descriptor files first for dependency caching
COPY project/build.properties project/build.properties
COPY project/plugins.sbt      project/plugins.sbt
COPY build.sbt                .

# Resolve and cache all dependencies (layer is reused when only src changes)
RUN sbt update

# Copy the application source and assemble the fat JAR
COPY src/ src/
RUN sbt assembly

# ─── Stage 2: Runtime ────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Copy the assembled fat JAR from the build stage
COPY --from=builder /build/target/scala-2.13/ingestion.jar ingestion.jar

# Directory that CSV source files will be mounted into at runtime
VOLUME ["/data"]

# ── Runtime configuration (overrideable at `docker run` time) ─────────────────
# Matches the keys in application.conf, so no source changes are needed.
ENV KAFKA_BOOTSTRAP_SERVERS=kafka:9092
ENV SALES_CSV_PATH=/data/sales.csv
ENV SALES_TOPIC=sales-raw

ENTRYPOINT ["java", "-jar", "ingestion.jar"]
