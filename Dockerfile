# Use Maven + JDK to build the project
FROM maven:3.9.1-eclipse-temurin-21 AS build

# Set working directory
WORKDIR /app

# Copy project files
COPY pom.xml .
COPY src ./src

# Build WAR
RUN mvn clean package

# Use Tomcat for runtime
FROM tomcat:9.0

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from build stage
COPY --from=build /app/target/BankSystem-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

