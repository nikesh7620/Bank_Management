# Use Tomcat 10.1 with JDK 21
FROM tomcat:10.1-jdk21

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your WAR file to ROOT.war (so it's served at "/")
COPY target/BankSystem-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]