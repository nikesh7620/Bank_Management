package Servlets;

import db.AS400Connection;

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

@WebServlet("/validateCredential")
public class validateCredential extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = request.getParameter("userId");
        String password = request.getParameter("password");

        String loginQuery =
            "SELECT uId FROM NIKESHM1.LOGMST WHERE uId = ? AND upass = ?";

        String custQuery =
            "SELECT accnbr, cname, acctyp, crtdt, status FROM NIKESHM1.CUSTMST";

        try (Connection conn = AS400Connection.getConnection();
             PreparedStatement loginPs = conn.prepareStatement(loginQuery)) {

            loginPs.setString(1, userId);
            loginPs.setString(2, password);

            ResultSet loginRs = loginPs.executeQuery();

            if (loginRs.next()) {

                // Prevent session fixation
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }

                HttpSession session = request.getSession(true);
                session.setAttribute("user", userId);

                // Load ALL customer records
                List<Map<String, String>> accounts = new ArrayList<>();

                try (PreparedStatement custPs = conn.prepareStatement(custQuery);
                     ResultSet custRs = custPs.executeQuery()) {

                    while (custRs.next()) {
                        Map<String, String> acc = new HashMap<>();
                        acc.put("accNo", custRs.getString("accnbr"));
                        acc.put("clientName", custRs.getString("cname"));
                        acc.put("accType", custRs.getString("acctyp"));
                        acc.put("createDate",
                                String.valueOf(custRs.getDate("crtdt")));
                        acc.put("status", custRs.getString("status"));

                        accounts.add(acc);
                    }
                }

                // Store data in SESSION (important)
                session.setAttribute("accounts", accounts);

                // Redirect → URL will change
                response.sendRedirect("BankDashBoard.jsp");

            } else {
                request.getSession().setAttribute(
                        "loginError", "Invalid Credential");
                response.sendRedirect("login.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute(
                    "loginError", "Internal server error");
            response.sendRedirect("login.jsp");
        }
    }
}
