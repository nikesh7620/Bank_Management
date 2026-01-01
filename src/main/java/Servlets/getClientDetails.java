package Servlets;

import db.As400Connection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/GetClientDetails")
public class GetClientDetails extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accountNumber = request.getParameter("accountNumber");
        HttpSession session = request.getSession();

        // Clear previous session attributes
        session.removeAttribute("clientError");
        session.removeAttribute("accountNumber");
        session.removeAttribute("fullName");
        session.removeAttribute("dob");
        session.removeAttribute("phone");
        session.removeAttribute("email");
        session.removeAttribute("gender");
        session.removeAttribute("addressLine1");
        session.removeAttribute("addressLine2");
        session.removeAttribute("addressLine3");
        session.removeAttribute("city");
        session.removeAttribute("state");
        session.removeAttribute("country");
        session.removeAttribute("pincode");
        session.removeAttribute("accountType");
        session.removeAttribute("currency");
        session.removeAttribute("idType");
        session.removeAttribute("idNumber");

        if (accountNumber == null || accountNumber.trim().isEmpty()) {
            session.setAttribute("clientError", "Please enter a valid account number");
            response.sendRedirect("DisplayClient.jsp");
            return;
        }

        try (Connection con = As400Connection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT ACCNBR, ACCTYP, CNAME, GENDER, DOB, MOBNBR, EMAIL, " +
                 "ADDR1, ADDR2, ADDR3, CITY, STATE, COUNTRY, PINCDE, " +
                 "CURR, IDTYP, IDNBR FROM NIKESHM1.CUSTMST WHERE ACCNBR = ?")) {

            ps.setString(1, accountNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    session.setAttribute("accountNumber", rs.getString("ACCNBR"));
                    session.setAttribute("accountType", rs.getString("ACCTYP"));
                    session.setAttribute("fullName", rs.getString("CNAME"));
                    session.setAttribute("gender", rs.getString("GENDER"));

                    Date dob = rs.getDate("DOB");
                    session.setAttribute("dob", dob != null ? dob.toString() : "");

                    session.setAttribute("phone", rs.getString("MOBNBR"));
                    session.setAttribute("email", rs.getString("EMAIL"));
                    session.setAttribute("addressLine1", rs.getString("ADDR1"));
                    session.setAttribute("addressLine2", rs.getString("ADDR2"));
                    session.setAttribute("addressLine3", rs.getString("ADDR3"));
                    session.setAttribute("city", rs.getString("CITY"));
                    session.setAttribute("state", rs.getString("STATE"));
                    session.setAttribute("country", rs.getString("COUNTRY"));
                    session.setAttribute("pincode", rs.getString("PINCDE"));
                    session.setAttribute("currency", rs.getString("CURR"));
                    session.setAttribute("idType", rs.getString("IDTYP"));
                    session.setAttribute("idNumber", rs.getString("IDNBR"));
                } else {
                    session.setAttribute("clientError", "Account Number not found");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("clientError", "Internal server error. Please try again.");
        }

        // Redirect to JSP (data in session)
        response.sendRedirect("DisplayClient.jsp");
    }
}
