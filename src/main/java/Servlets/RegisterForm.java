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
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.newDocument();

            Element regDataElement = doc.createElement("registrationData");
            doc.appendChild(regDataElement);

            if (request.getParameter("pgmname") != null) {
                Element pgmElement = doc.createElement("pgmname");
                pgmElement.appendChild(doc.createTextNode(request.getParameter("pgmname")));
                regDataElement.appendChild(pgmElement);

                // MAIN FIELDS
                if (request.getParameter("Name") != null) {
                    Element nameElement = doc.createElement("Name");
                    nameElement.appendChild(doc.createTextNode(request.getParameter("Name")));
                    regDataElement.appendChild(nameElement);
                }

                if (request.getParameter("dob") != null) {
                    Element dobElement = doc.createElement("dob");
                    dobElement.appendChild(doc.createTextNode(request.getParameter("dob")));
                    regDataElement.appendChild(dobElement);
                }

                if (request.getParameter("Mobnbr") != null && request.getParameter("countryCode") != null) {
                    String countryCode = request.getParameter("countryCode");
                    String phone = request.getParameter("Mobnbr");
                    String fullPhone = countryCode + "-" + phone;

                    Element phoneElement = doc.createElement("Mobnbr");
                    phoneElement.appendChild(doc.createTextNode(fullPhone));
                    regDataElement.appendChild(phoneElement);
                }

                if (request.getParameter("email") != null) {
                    Element emailElement = doc.createElement("email");
                    emailElement.appendChild(doc.createTextNode(request.getParameter("email")));
                    regDataElement.appendChild(emailElement);
                }

                if (request.getParameter("gender") != null) {
                    Element genderElement = doc.createElement("gender");
                    genderElement.appendChild(doc.createTextNode(request.getParameter("gender")));
                    regDataElement.appendChild(genderElement);
                }

                // ADDRESS DETAILS
                if (request.getParameter("address1") != null) {
                    Element add1 = doc.createElement("address1");
                    add1.appendChild(doc.createTextNode(request.getParameter("address1")));
                    regDataElement.appendChild(add1);
                }

                if (request.getParameter("address2") != null) {
                    Element add2 = doc.createElement("address2");
                    add2.appendChild(doc.createTextNode(request.getParameter("address2")));
                    regDataElement.appendChild(add2);
                }

                if (request.getParameter("address3") != null) {
                    Element add3 = doc.createElement("address3");
                    add3.appendChild(doc.createTextNode(request.getParameter("address3")));
                    regDataElement.appendChild(add3);
                }

                if (request.getParameter("pincode") != null) {
                    Element pin = doc.createElement("pincode");
                    pin.appendChild(doc.createTextNode(request.getParameter("pincode")));
                    regDataElement.appendChild(pin);
                }

                if (request.getParameter("city") != null) {
                    Element city = doc.createElement("city");
                    city.appendChild(doc.createTextNode(request.getParameter("city")));
                    regDataElement.appendChild(city);
                }

                if (request.getParameter("state") != null) {
                    Element state = doc.createElement("state");
                    state.appendChild(doc.createTextNode(request.getParameter("state")));
                    regDataElement.appendChild(state);
                }

                if (request.getParameter("country") != null) {
                    Element country = doc.createElement("country");
                    country.appendChild(doc.createTextNode(request.getParameter("country")));
                    regDataElement.appendChild(country);
                }

                // ACCOUNT DETAILS
                if (request.getParameter("accType") != null) {
                    Element accType = doc.createElement("accType");
                    accType.appendChild(doc.createTextNode(request.getParameter("accType")));
                    regDataElement.appendChild(accType);
                }

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

                // ID DETAILS
                if (request.getParameter("idType") != null) {
                    Element idType = doc.createElement("idType");
                    idType.appendChild(doc.createTextNode(request.getParameter("idType")));
                    regDataElement.appendChild(idType);
                }

                if (request.getParameter("idNumber") != null) {
                    Element idNumber = doc.createElement("idNumber");
                    idNumber.appendChild(doc.createTextNode(request.getParameter("idNumber")));
                    regDataElement.appendChild(idNumber);
                }
            }

            // TRANSFORM XML
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty(OutputKeys.ENCODING, "Cp037");

            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));
            String xml = writer.toString();

            // MULTI-USER XML handling
            String inputFilePath = XMLWriter.writeOrderToIFS(xml);
            XMLWriter.callRPGProgram();
            Map resultMsg = XMLWriter.readResponseFromIFS();

            // STORE RESPONSE MESSAGE AND SESSION ATTRIBUTES
            request.getSession().setAttribute("responseMessage", resultMsg.get("responseMessage"));
            request.getSession().setAttribute("responseCode", resultMsg.get("responseCode"));

            if ("1".equals(resultMsg.get("responseCode"))) {
                // FULL SESSION HANDLING (exactly as original)
                request.getSession().setAttribute("Name", request.getParameter("Name"));
                request.getSession().setAttribute("dob", request.getParameter("dob"));
                request.getSession().setAttribute("countryCode", request.getParameter("countryCode"));
                request.getSession().setAttribute("Mobnbr", request.getParameter("Mobnbr"));
                request.getSession().setAttribute("email", request.getParameter("email"));
                request.getSession().setAttribute("gender", request.getParameter("gender"));

                request.getSession().setAttribute("address1", request.getParameter("address1"));
                request.getSession().setAttribute("address2", request.getParameter("address2"));
                request.getSession().setAttribute("address3", request.getParameter("address3"));
                request.getSession().setAttribute("pincode", request.getParameter("pincode"));
                request.getSession().setAttribute("city", request.getParameter("city"));
                request.getSession().setAttribute("state", request.getParameter("state"));
                request.getSession().setAttribute("country", request.getParameter("country"));

                request.getSession().setAttribute("accType", request.getParameter("accType"));
                request.getSession().setAttribute("currency", request.getParameter("currency"));
                request.getSession().setAttribute("otherCurrency", request.getParameter("otherCurrency"));

                request.getSession().setAttribute("idType", request.getParameter("idType"));
                request.getSession().setAttribute("idNumber", request.getParameter("idNumber"));
            } else {
                // Remove all attributes exactly as original
                request.getSession().removeAttribute("Name");
                request.getSession().removeAttribute("dob");
                request.getSession().removeAttribute("countryCode");
                request.getSession().removeAttribute("Mobnbr");
                request.getSession().removeAttribute("email");
                request.getSession().removeAttribute("gender");

                request.getSession().removeAttribute("address1");
                request.getSession().removeAttribute("address2");
                request.getSession().removeAttribute("address3");
                request.getSession().removeAttribute("pincode");
                request.getSession().removeAttribute("city");
                request.getSession().removeAttribute("state");
                request.getSession().removeAttribute("country");

                request.getSession().removeAttribute("accType");
                request.getSession().removeAttribute("currency");
                request.getSession().removeAttribute("otherCurrency");

                request.getSession().removeAttribute("idType");
                request.getSession().removeAttribute("idNumber");
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
