package db;

import java.sql.Connection;
import java.sql.DriverManager;

public class As400Connection {

    public static Connection getConnection() throws Exception {

        // 1. Try JVM system properties (Render)
        String host = System.getProperty("AS400_HOST");
        String user = System.getProperty("AS400_USER");
        String password = System.getProperty("AS400_PASSWORD");

        // 2. Fallback to environment variables (local)
        if (host == null) host = System.getenv("AS400_HOST");
        if (user == null) user = System.getenv("AS400_USER");
        if (password == null) password = System.getenv("AS400_PASSWORD");

        // 3. Throw clear error if still missing
        if (host == null || user == null || password == null) {
            throw new RuntimeException(
                "AS400 connection not configured. " +
                "Set JVM system properties or environment variables."
            );
        }

        // 4. Build JDBC URL
        String url = host.startsWith("jdbc:") ? host : "jdbc:as400://" + host;

        // 5. Load AS400 JDBC driver
        Class.forName("com.ibm.as400.access.AS400JDBCDriver");

        // 6. Connect
        return DriverManager.getConnection(url, user, password);
    }
}
