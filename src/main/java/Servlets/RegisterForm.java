package Servlets;

import java.io.IOException;
import java.io.StringWriter;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import utils.XMLWriter;

@WebServlet("/RegisterForm")
public class RegisterForm extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            /* -------------------------------------------------
             * 1. BUILD XML DOCUMENT
             * ------------------------------------------------- */
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.newDocument();

            Element root = doc.createElement("registrationData");
            doc.appendChild(root);

            // Simple fields
            String[] fields = {
                "pgmname", "Name", "dob", "email", "gender",
                "address1", "address2", "address3",
                "pincode", "city", "state", "country",
                "accType", "idType", "idNumber"
            };

            for (String f : fields) {
                String val = request.getParameter(f);
                if (val != null && !val.isEmpty()) {
                    Element e = doc.createElement(f);
                    e.appendChild(doc.createTextNode(val));
                    root.appendChild(e);
                }
            }

            /* Phone number */
            String mob = request.getParameter("Mobnbr");
            String cc = request.getParameter("countryCode");
            if (mob != null && cc != null) {
                Element phone = doc.createElement("Mobnbr");
                phone.appendChild(doc.createTextNode(cc + "-" + mob));
                root.appendChild(phone);
            }

            /* Currency */
            String currency = request.getParameter("currency");
            if (currency != null) {
                Element cur = doc.createElement("currency");
                if ("OTH".equals(currency)) {
                    String oth = request.getParameter("otherCurrency");
                    cur.appendChild(doc.createTextNode(oth != null ? oth : ""));
                } else {
                    cur.appendChild(doc.createTextNode(currency));
                }
                root.appendChild(cur);
            }

            /* -------------------------------------------------
             * 2. TRANSFORM XML TO STRING
             * ------------------------------------------------- */
            Transformer transformer = TransformerFactory.newInstance().newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty(OutputKeys.ENCODING, "Cp037");

            StringWriter sw = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(sw));
            String xmlData = sw.toString();

            /* -------------------------------------------------
             * 3. WRITE INPUT XML (THREAD SAFE)
             * ------------------------------------------------- */
            String inputXmlPath = XMLWriter.writeOrderToIFS(xmlData);
            // Example:
            // /home/NIKESHM/bankInp_1.xml
            // /home/NIKESHM/bankInp_2.xml

            /* -------------------------------------------------
             * 4. CALL RPG PROGRAM
             * ------------------------------------------------- */
            XMLWriter.callRPGProgram(inputXmlPath);

            /* -------------------------------------------------
             * 5. READ OUTPUT XML
             * ------------------------------------------------- */
            String outputXmlPath = inputXmlPath.replace("bankInp_", "bankOUT_");
            Map<String, String> result = XMLWriter.readResponseFromIFS(inputXmlPath);

            /* -------------------------------------------------
             * 6. SESSION HANDLING
             * ------------------------------------------------- */
            request.getSession().setAttribute("responseMessage", result.get("responseMessage"));
            request.getSession().setAttribute("responseCode", result.get("responseCode"));

            if ("1".equals(result.get("responseCode"))) {
                for (String f : fields) {
                    request.getSession().setAttribute(f, request.getParameter(f));
                }
                request.getSession().setAttribute("Mobnbr", mob);
                request.getSession().setAttribute("countryCode", cc);
                request.getSession().setAttribute("currency", currency);
                request.getSession().setAttribute("otherCurrency",
                        request.getParameter("otherCurrency"));
            } else {
                request.getSession().invalidate();
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute(
                    "responseMessage",
                    "✖ System Error: " + e.getMessage());
        }

        /* -------------------------------------------------
         * 7. REDIRECT
         * ------------------------------------------------- */
        response.sendRedirect(request.getParameter("redirectPage"));
    }
}