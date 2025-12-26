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

    @SuppressWarnings({"CallToPrintStackTrace", "override"})
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Build XML from form data
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.newDocument();

            Element regDataElement = doc.createElement("registrationData");
            doc.appendChild(regDataElement);

            // Populate XML fields
            String[] fields = { "pgmname", "Name", "dob", "email", "gender", "address1", "address2", "address3",
                                "pincode", "city", "state", "country", "accType", "idType", "idNumber", "currency" };

            for (String field : fields) {
                String value = request.getParameter(field);
                if (value != null) {
                    Element element = doc.createElement(field);
                    element.appendChild(doc.createTextNode(value));
                    regDataElement.appendChild(element);
                }
            }

            // Handle phone number
            String mob = request.getParameter("Mobnbr");
            String countryCode = request.getParameter("countryCode");
            if (mob != null && countryCode != null) {
                Element phoneElement = doc.createElement("Mobnbr");
                phoneElement.appendChild(doc.createTextNode(countryCode + "-" + mob));
                regDataElement.appendChild(phoneElement);
            }

            // Handle currency special case
            String currency = request.getParameter("currency");
            if (currency != null) {
                Element curr = doc.createElement("currency");
                if ("OTH".equals(currency)) {
                    String actualCurrency = request.getParameter("otherCurrency");
                    curr.appendChild(doc.createTextNode(actualCurrency != null ? actualCurrency : ""));
                } else {
                    curr.appendChild(doc.createTextNode(currency));
                }
                regDataElement.appendChild(curr);
            }

            // Convert XML to String
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty(OutputKeys.ENCODING, "Cp037");

            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));
            String xml = writer.toString();

            // Write XML to IFS with sequential filename
            String xmlPath = XMLWriter.writeOrderToIFS(xml);

            // Call RPG program
            XMLWriter.callRPGProgram(xmlPath);

            // Construct output XML path (replace "bankInp_" with "bankOUT_")
            String outXmlPath = xmlPath.replace("bankInp_", "bankOUT_");

            // Read response from RPG output XML
            Map<String, String> resultMsg = XMLWriter.readResponseFromIFS(outXmlPath);

            // SESSION HANDLING
            request.getSession().setAttribute("responseMessage", resultMsg.get("responseMessage"));
            request.getSession().setAttribute("responseCode", resultMsg.get("responseCode"));

            if ("1".equals(resultMsg.get("responseCode"))) {
                // Save submitted form data to session
                for (String field : new String[]{ "Name", "dob", "countryCode", "Mobnbr", "email", "gender",
                        "address1", "address2", "address3", "pincode", "city", "state", "country",
                        "accType", "currency", "otherCurrency", "idType", "idNumber"}) {
                    request.getSession().setAttribute(field, request.getParameter(field));
                }
            } else {
                // Clear session data on error
                for (String field : new String[]{ "Name", "dob", "countryCode", "Mobnbr", "email", "gender",
                        "address1", "address2", "address3", "pincode", "city", "state", "country",
                        "accType", "currency", "otherCurrency", "idType", "idNumber"}) {
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

        // Redirect to page specified in form
        response.sendRedirect(request.getParameter("redirectPage"));
    }
}
