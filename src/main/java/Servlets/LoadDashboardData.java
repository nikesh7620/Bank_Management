package Servlets;

import db.As400Connection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoadDashboardData")
public class LoadDashboardData extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String custQuery = "SELECT accnbr, cname, acctyp, crtdt, status FROM NIKESHM1.CUSTMST ORDER BY Accnbr";

        try (Connection conn = As400Connection.getConnection();
             PreparedStatement custPs = conn.prepareStatement(custQuery);
             ResultSet custRs = custPs.executeQuery()) {

            List<Map<String, String>> accounts = new ArrayList<>();
            while (custRs.next()) {
                Map<String, String> acc = new HashMap<>();
                acc.put("accNo", custRs.getString("accnbr"));
                acc.put("clientName", custRs.getString("cname"));
                acc.put("accType", custRs.getString("acctyp"));
                acc.put("createDate", String.valueOf(custRs.getDate("crtdt")));
                acc.put("status", custRs.getString("status"));
                accounts.add(acc);
            }

            session.setAttribute("accounts", accounts);

            // Redirect to dashboard JSP
            response.sendRedirect("BankDashBoard.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("loginError", "Error loading dashboard data");
            response.sendRedirect("Login.jsp");
        }
    }
}
