package Servlets;

import db.As400Connection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ValidateCredentials")
public class ValidateCredentials extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = request.getParameter("userId");
        String password = request.getParameter("password");

        String loginQuery = "SELECT uId FROM NIKESHM1.LOGMST WHERE uId = ? AND upass = ?";

        try (Connection conn = As400Connection.getConnection();
             PreparedStatement loginPs = conn.prepareStatement(loginQuery)) {

            loginPs.setString(1, userId);
            loginPs.setString(2, password);

            ResultSet loginRs = loginPs.executeQuery();

            if (loginRs.next()) {

                // Prevent session fixation
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) oldSession.invalidate();

                HttpSession session = request.getSession(true);
                session.setAttribute("user", userId);

                // Redirect to LoadDashboardData servlet to fetch accounts
                response.sendRedirect("LoadDashboardData");

            } else {
                request.getSession().setAttribute("loginError", "Invalid Credential");
                response.sendRedirect("Login.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("loginError", "Internal server error");
            response.sendRedirect("Login.jsp");
        }
    }
}
