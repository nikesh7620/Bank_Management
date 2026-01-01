package db;

import java.sql.Connection;
import java.sql.DriverManager;

public class As400Connection {

    public static Connection getConnection() throws Exception {

        String host = System.getenv("AS400_HOST");
        String user = System.getenv("AS400_USER");
        String password = System.getenv("AS400_PASSWORD");

        // Fail fast if not configured
        if (host == null || user == null || password == null) {
            throw new RuntimeException(
                "AS400 environment variables not configured. " +
                "Please set AS400_HOST, AS400_USER, AS400_PASSWORD"
            );
        }

        String url = "jdbc:as400://" + host;

        Class.forName("com.ibm.as400.access.AS400JDBCDriver");

        return DriverManager.getConnection(url, user, password);
    }
}
