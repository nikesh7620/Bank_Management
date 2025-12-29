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
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import utils.XMLWriter;

@WebServlet("/RegisterForm")
public class RegisterForm extends HttpServlet {

    @SuppressWarnings("override")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Build XML
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.newDocument();

            Element regDataElement = doc.createElement("registrationData");
            doc.appendChild(regDataElement);

            if (request.getParameter("pgmname") != null) {
                Element pgmElement = doc.createElement("pgmname");
                pgmElement.appendChild(doc.createTextNode(request.getParameter("pgmname")));
                regDataElement.appendChild(pgmElement);

                // Add fields dynamically
                appendElementIfNotNull(doc, regDataElement, "Name", request.getParameter("Name"));
                appendElementIfNotNull(doc, regDataElement, "dob", request.getParameter("dob"));

                String mob = request.getParameter("Mobnbr");
                String countryCode = request.getParameter("countryCode");
                if (mob != null && countryCode != null) {
                    appendElementIfNotNull(doc, regDataElement, "Mobnbr", countryCode + "-" + mob);
                }

                appendElementIfNotNull(doc, regDataElement, "email", request.getParameter("email"));
                appendElementIfNotNull(doc, regDataElement, "gender", request.getParameter("gender"));

                // Address
                appendElementIfNotNull(doc, regDataElement, "address1", request.getParameter("address1"));
                appendElementIfNotNull(doc, regDataElement, "address2", request.getParameter("address2"));
                appendElementIfNotNull(doc, regDataElement, "address3", request.getParameter("address3"));
                appendElementIfNotNull(doc, regDataElement, "pincode", request.getParameter("pincode"));
                appendElementIfNotNull(doc, regDataElement, "city", request.getParameter("city"));
                appendElementIfNotNull(doc, regDataElement, "state", request.getParameter("state"));
                appendElementIfNotNull(doc, regDataElement, "country", request.getParameter("country"));

                // Account
                appendElementIfNotNull(doc, regDataElement, "accType", request.getParameter("accType"));

                String currency = request.getParameter("currency");
                if (currency != null) {
                    if ("OTH".equals(currency)) {
                        appendElementIfNotNull(doc, regDataElement, "currency", request.getParameter("otherCurrency"));
                    } else {
                        appendElementIfNotNull(doc, regDataElement, "currency", currency);
                    }
                }

                // ID
                appendElementIfNotNull(doc, regDataElement, "idType", request.getParameter("idType"));
                appendElementIfNotNull(doc, regDataElement, "idNumber", request.getParameter("idNumber"));
            }

            // Transform XML
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty(OutputKeys.ENCODING, "Cp037"); // AS400 EBCDIC

            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));
            String xml = writer.toString();

            // Write XML to IFS
            String inputFilePath = XMLWriter.writeOrderToIFS(xml);

            // Call RPG program
            XMLWriter.callRPGProgram();

            // Read response
            Map<String, String> resultMsg = XMLWriter.readResponseFromIFS(inputFilePath);

            // Session handling
            request.getSession().setAttribute("responseMessage", resultMsg.get("responseMessage"));
            request.getSession().setAttribute("responseCode", resultMsg.get("responseCode"));

            if ("1".equals(resultMsg.get("responseCode"))) {
                String[] fields = {"Name","dob","countryCode","Mobnbr","email","gender","address1","address2","address3",
                        "pincode","city","state","country","accType","currency","otherCurrency","idType","idNumber"};
                for (String field : fields) {
                    request.getSession().setAttribute(field, request.getParameter(field));
                }
            } else {
                String[] fields = {"Name","dob","countryCode","Mobnbr","email","gender","address1","address2","address3",
                        "pincode","city","state","country","accType","currency","otherCurrency","idType","idNumber"};
                for (String field : fields) {
                    request.getSession().removeAttribute(field);
                }
            }

        } catch (ParserConfigurationException | TransformerException e) {
            e.printStackTrace();
            request.getSession().setAttribute("responseMessage", "✖ Error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("responseMessage", "✖ Unexpected Error: " + e.getMessage());
        }

        response.sendRedirect(request.getParameter("redirectPage"));
    }

    private void appendElementIfNotNull(Document doc, Element parent, String tag, String value) {
        if (value != null && !value.trim().isEmpty()) {
            Element e = doc.createElement(tag);
            e.appendChild(doc.createTextNode(value.trim()));
            parent.appendChild(e);
        }
    }
}
