package Servlets;

import java.io.IOException;
import java.io.StringWriter;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        try {
            // 1. Build XML
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.newDocument();

            Element regDataElement = doc.createElement("registrationData");
            doc.appendChild(regDataElement);

            if (request.getParameter("pgmname") != null) {
                // program name
                Element pgmElement = doc.createElement("pgmname");
                pgmElement.appendChild(doc.createTextNode(request.getParameter("pgmname")));
                regDataElement.appendChild(pgmElement);

                // main fields
                String[] fields = { "Name", "dob", "Mobnbr", "email", "gender", "address1", "address2",
                        "address3", "pincode", "city", "state", "country", "accType", "currency", "otherCurrency",
                        "idType", "idNumber", "countryCode" };

                for (String field : fields) {
                    String value = request.getParameter(field);
                    if (value != null) {
                        Element elem = doc.createElement(field);
                        elem.appendChild(doc.createTextNode(value));
                        regDataElement.appendChild(elem);
                    }
                }

                // Combine country code and mobile
                if (request.getParameter("Mobnbr") != null && request.getParameter("countryCode") != null) {
                    String fullPhone = request.getParameter("countryCode") + "-" + request.getParameter("Mobnbr");
                    Element phoneElem = doc.createElement("Mobnbr");
                    phoneElem.appendChild(doc.createTextNode(fullPhone));
                    regDataElement.appendChild(phoneElem);
                }
            }

            // Transform XML to string
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty(OutputKeys.ENCODING, "Cp037");

            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));
            String xmlString = writer.toString();

            // --- 2. Generate unique file names per user session ---
            String sessionId = session.getId();
            String xmlFileName = "/home/NIKESHM/bankInp_" + sessionId + ".xml";
            String responseFileName = "/home/NIKESHM/bankOUT_" + sessionId + ".xml";

            // --- 3. Write XML to IFS and call RPG program ---
            XMLWriter.writeOrderToIFS(xmlString, xmlFileName);
            XMLWriter.callRPGProgram(xmlFileName, responseFileName);

            // --- 4. Read response for this user ---
            Map<String, String> resultMsg = XMLWriter.readResponseFromIFS(responseFileName);

            // --- 5. Store response in session ---
            session.setAttribute("responseMessage", resultMsg.get("responseMessage"));
            session.setAttribute("responseCode", resultMsg.get("responseCode"));

            // --- 6. Store or remove user fields based on response ---
            if ("1".equals(resultMsg.get("responseCode"))) {
                String[] storeFields = { "Name", "dob", "countryCode", "Mobnbr", "email", "gender", "address1",
                        "address2", "address3", "pincode", "city", "state", "country", "accType", "currency",
                        "otherCurrency", "idType", "idNumber" };
                for (String field : storeFields) {
                    session.setAttribute(field, request.getParameter(field));
                }
            } else {
                String[] removeFields = { "Name", "dob", "countryCode", "Mobnbr", "email", "gender", "address1",
                        "address2", "address3", "pincode", "city", "state", "country", "accType", "currency",
                        "otherCurrency", "idType", "idNumber" };
                for (String field : removeFields) {
                    session.removeAttribute(field);
                }
            }

        } catch (ParserConfigurationException | TransformerException e) {
            e.printStackTrace();
            session.setAttribute("responseMessage", "✖ Error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("responseMessage", "✖ Unexpected Error: " + e.getMessage());
        }

        // Redirect back to the requested page
        response.sendRedirect(request.getParameter("redirectPage"));
    }
}
