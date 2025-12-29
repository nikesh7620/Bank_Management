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
            // 1️⃣ Build XML
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.newDocument();

            Element regDataElement = doc.createElement("registrationData");
            doc.appendChild(regDataElement);

            String[] fields = {"pgmname","Name","dob","Mobnbr","email","gender",
                    "address1","address2","address3","pincode","city","state","country",
                    "accType","currency","idType","idNumber"};

            for (String field : fields) {
                String value = request.getParameter(field);
                if (value != null) {
                    if ("currency".equals(field) && "OTH".equals(value)) {
                        value = request.getParameter("otherCurrency");
                    }
                    if ("Mobnbr".equals(field) && request.getParameter("countryCode") != null) {
                        value = request.getParameter("countryCode") + "-" + value;
                    }
                    Element element = doc.createElement(field);
                    element.appendChild(doc.createTextNode(value));
                    regDataElement.appendChild(element);
                }
            }

            // 2️⃣ Transform to XML string
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty(OutputKeys.ENCODING, "Cp037");

            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));
            String xmlString = writer.toString();

            // 3️⃣ Write XML to AS400 IFS (dynamic file)
            String xmlFilePath = XMLWriter.writeOrderToIFS(xmlString);

            // Determine bankInpX.xml index
            int fileIndex = Integer.parseInt(xmlFilePath.replaceAll("\\D+", ""));

            // 4️⃣ Call RPG program
            XMLWriter.callRPGProgram("/QSYS.LIB/NIKESHM1.LIB/BANKTST.PGM");

            // 5️⃣ Read corresponding bankOutX.xml
            String outputFileName = "bankOut" + fileIndex + ".xml";
            Map<String, String> resultMsg = XMLWriter.readResponseFromIFS(outputFileName);

            request.getSession().setAttribute("responseMessage", resultMsg.get("responseMessage"));
            request.getSession().setAttribute("responseCode", resultMsg.get("responseCode"));

            // 6️⃣ Manage session attributes
            if ("1".equals(resultMsg.get("responseCode"))) {
                for (String field : fields) {
                    request.getSession().setAttribute(field, request.getParameter(field));
                }
            } else {
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
}
