FROM maven:3.9.0-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

RUN ls -la /app/target/

FROM eclipse-temurin:17.0.6_10-jdk
WORKDIR /app

COPY --from=build /app/target/devops-integration.jar /app/
EXPOSE 8080
CMD ["java", "-jar", "devops-integration.jar"]