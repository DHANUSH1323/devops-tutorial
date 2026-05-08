#stage 1: build the application
FROM maven:3.8.4-openjdk-17-slim AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests


#Step2: runtime
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /app/target/devops-app.jar ./app.jar
EXPOSE 8000
ENV PORT=8000
ENTRYPOINT ["java", "-jar", "/app/app.jar"]