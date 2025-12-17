package db;

import java.sql.*;

public class AS400Connection {
    
    private static final String URL = "jdbc:as400://PUB400.COM";
    private static final String USER = "NIKESHM";
    private static final String PASSWORD = "zoro@404";

    public static Connection getConnection() throws Exception
    {
        Class.forName("com.ibm.as400.access.AS400JDBCDriver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}