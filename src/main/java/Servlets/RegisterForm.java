package Servlets;

import utils.XMLWriter;

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

import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/RegisterForm")
public class RegisterForm extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String[] records = request.getParameterValues("record");
            boolean singleRecord = (records == null || records.length == 0) && request.getParameter("pgmname") != null;

            List<String> inputFiles = new ArrayList<>();
            List<String> outputFiles = new ArrayList<>();

            int totalRecords = singleRecord ? 1 : records.length;

            for (int i = 0; i < totalRecords; i++) {

                DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                DocumentBuilder builder = factory.newDocumentBuilder();
                Document doc = builder.newDocument();

                Element regDataElement = doc.createElement("registrationData");
                doc.appendChild(regDataElement);

                String[] fields = {"pgmname","Name","dob","Mobnbr","email","gender",
                        "address1","address2","address3","pincode","city","state","country",
                        "accType","currency","idType","idNumber"};

                for (String field : fields) {
                    String value;
                    if (singleRecord) {
                        value = request.getParameter(field);
                        if ("currency".equals(field) && "OTH".equals(value)) {
                            value = request.getParameter("otherCurrency");
                        }
                        if ("Mobnbr".equals(field) && request.getParameter("countryCode") != null) {
                            value = request.getParameter("countryCode") + "-" + value;
                        }
                    } else {
                        value = request.getParameter(field + "_" + (i + 1));
                        if ("currency".equals(field) && "OTH".equals(value)) {
                            value = request.getParameter("otherCurrency_" + (i + 1));
                        }
                        if ("Mobnbr".equals(field) && request.getParameter("countryCode_" + (i + 1)) != null) {
                            value = request.getParameter("countryCode_" + (i + 1)) + "-" + value;
                        }
                    }

                    if (value != null) {
                        Element element = doc.createElement(field);
                        element.appendChild(doc.createTextNode(value));
                        regDataElement.appendChild(element);
                    }
                }

                TransformerFactory transformerFactory = TransformerFactory.newInstance();
                Transformer transformer = transformerFactory.newTransformer();
                transformer.setOutputProperty(OutputKeys.INDENT, "yes");
                transformer.setOutputProperty(OutputKeys.ENCODING, "Cp037");

                StringWriter writer = new StringWriter();
                transformer.transform(new DOMSource(doc), new StreamResult(writer));
                String xmlString = writer.toString();

                String xmlFilePath = XMLWriter.writeOrderToIFS(xmlString);
                inputFiles.add(xmlFilePath);

                String outFileName = xmlFilePath.replace("bankInp", "bankOut");
                outputFiles.add(outFileName);
            }

            // ✅ Pass correct parameters to RPG
            XMLWriter.callRPGProgram(inputFiles, outputFiles);

            List<String> messages = new ArrayList<>();
            List<String> codes = new ArrayList<>();
            for (String outFile : outputFiles) {
                Map<String, String> result = XMLWriter.readResponseFromIFS(outFile);
                messages.add(result.get("responseMessage"));
                codes.add(result.get("responseCode"));
            }

            request.getSession().setAttribute("responseMessages", messages);
            request.getSession().setAttribute("responseCodes", codes);

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("responseMessage", "✖ Error: " + e.getMessage());
        }

        response.sendRedirect(request.getParameter("redirectPage"));
    }
}
