package Servlets;

import db.AS400Connection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/getClientDetails")
public class getClientDetails extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accountNumber = request.getParameter("accountNumber");

        try (Connection con = AS400Connection.getConnection()) {

            String sql =
                "SELECT ACCNBR, ACCTYP, CNAME, GENDER, DOB, MOBNBR, EMAIL, " +
                "ADDR1, ADDR2, ADDR3, CITY, STATE, COUNTRY, PINCDE, " +
                "CURR, IDTYP, IDNBR " +
                "FROM NIKESHM1.CUSTMST WHERE ACCNBR = ?";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, accountNumber);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Store in request attributes
                request.setAttribute("accountNumber", rs.getString("ACCNBR"));
                request.setAttribute("accountType", rs.getString("ACCTYP"));
                request.setAttribute("fullName", rs.getString("CNAME"));
                request.setAttribute("gender", rs.getString("GENDER"));
                request.setAttribute("dob", rs.getString("DOB"));
                request.setAttribute("phone", rs.getString("MOBNBR"));
                request.setAttribute("email", rs.getString("EMAIL"));
                request.setAttribute("addressLine1", rs.getString("ADDR1"));
                request.setAttribute("addressLine2", rs.getString("ADDR2"));
                request.setAttribute("addressLine3", rs.getString("ADDR3"));
                request.setAttribute("city", rs.getString("CITY"));
                request.setAttribute("state", rs.getString("STATE"));
                request.setAttribute("country", rs.getString("COUNTRY"));
                request.setAttribute("pincode", rs.getString("PINCDE"));
                request.setAttribute("currency", rs.getString("CURR"));
                request.setAttribute("idType", rs.getString("IDTYP"));
                request.setAttribute("idNumber", rs.getString("IDNBR"));
            } else {
                request.setAttribute("clientError", "Account Number not found");
            }

            rs.close();
            ps.close();

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("clientError", "Internal Server Error. Please try again.");
        }

        // Forward back to JSP
        request.getRequestDispatcher("DisplayClient.jsp").forward(request, response);
    }
}
