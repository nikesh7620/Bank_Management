package db;

import java.sql.Connection;
import java.sql.DriverManager;

public class As400Connection {

    public static Connection getConnection() throws Exception {
        String host = System.getProperty("AS400_HOST");
        String user = System.getProperty("AS400_USER");
        String password = System.getProperty("AS400_PASSWORD");

        if (host == null) host = System.getenv("AS400_HOST");
        if (user == null) user = System.getenv("AS400_USER");
        if (password == null) password = System.getenv("AS400_PASSWORD");

        if (host == null || user == null || password == null) {
            throw new RuntimeException(
                "AS400 connection not configured. " +
                "Set JVM system properties or environment variables."
            );
        }

        // Build JDBC URL
        String url = "jdbc:as400://" + host;

        Class.forName("com.ibm.as400.access.AS400JDBCDriver");
        return DriverManager.getConnection(url, user, password);
    }
}
