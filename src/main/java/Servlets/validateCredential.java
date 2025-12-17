package Servlets;

import db.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/validateCredential")
public class validateCredential extends HttpServlet{

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String UserId = request.getParameter("userId");
        String Password = request.getParameter("password");
        String query = "SELECT * FROM NIKESHM1.LOGMST WHERE uId = ? AND upass = ?";

        
        try (Connection conn = AS400Connection.getConnection();
            PreparedStatement pStatement = conn.prepareStatement(query)) {

            pStatement.setString(1, UserId);
            pStatement.setString(2, Password);
            ResultSet rs = pStatement.executeQuery();

            if (rs.next()) {
                request.getSession().setAttribute("user", UserId);
                response.sendRedirect("BankDashBoard.jsp");
            } else {
                request.getSession().setAttribute("loginError", "Invalid Credential");
                response.sendRedirect("login.jsp");
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("loginError", "Internal server error.");
            response.sendRedirect("login.jsp");
        }
    }
}