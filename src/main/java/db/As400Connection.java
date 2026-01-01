package db;

import java.sql.Connection;
import java.sql.DriverManager;

public class As400Connection {

    public static Connection getConnection() throws Exception {

        // Read JVM system properties (Render-safe)
        String host = System.getProperty("AS400_HOST");
        String user = System.getProperty("AS400_USER");
        String password = System.getProperty("AS400_PASSWORD");

        if (host == null || user == null || password == null) {
            throw new RuntimeException(
                "AS400 system properties not configured. " +
                "Check JAVA_OPTS in Render."
            );
        }

        String url = "jdbc:as400://" + host;

        Class.forName("com.ibm.as400.access.AS400JDBCDriver");

        return DriverManager.getConnection(url, user, password);
    }
}
