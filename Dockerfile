# ==========================
# Stage 1 - Build
# ==========================
FROM maven:3.9.11-eclipse-temurin-25 AS builder

WORKDIR /app

# Copy Maven files first (better Docker caching)
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
RUN chmod +x mvnw

# Download dependencies
RUN ./mvnw dependency:go-offline

# Copy source code
COPY src src

# Build application
RUN ./mvnw clean package -DskipTests

# ==========================
# Stage 2 - Runtime
# ==========================
FROM eclipse-temurin:25-jre

WORKDIR /app

# Copy generated jar
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]