# ---- Build Stage ----
FROM sbtscala/scala-sbt:eclipse-temurin-21.0.3_9_1.10.0_2.13.14 AS builder

WORKDIR /build

# Copy sbt definition first to cache dependency downloads on rebuild
COPY src/ingestion/build.sbt ./
COPY src/ingestion/project ./project
RUN sbt update

# Copy source and assemble fat JAR
COPY src/ingestion/src ./src
RUN sbt assembly

# ---- Run Stage ----
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=builder /build/target/scala-2.13/ingestion-assembly-0.1.0.jar app.jar
COPY src/sources/filesystem/products.csv /data/products.csv

ENV KAFKA_BOOTSTRAP_SERVERS=kafka:9092 \
    PRODUCTS_CSV_PATH=/data/products.csv \
    PRODUCTS_TOPIC=products-raw

ENTRYPOINT ["java", "-jar", "app.jar"]
