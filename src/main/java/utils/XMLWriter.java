package utils;

import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.IFSFile;
import com.ibm.as400.access.IFSFileInputStream;
import com.ibm.as400.access.IFSFileOutputStream;
import com.ibm.as400.access.ProgramCall;

public class XMLWriter {

    @SuppressWarnings("CallToPrintStackTrace")
    public static void writeOrderToIFS(String xmlData) throws Exception {
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");
        String ifsPath = "/home/NIKESHM/bankInp.xml";
        IFSFile file = new IFSFile(system, ifsPath);

        try (Writer writer = new OutputStreamWriter(
                new IFSFileOutputStream(file, IFSFileOutputStream.SHARE_ALL, false),
                "Cp037")) {
            writer.write(xmlData);
            writer.flush();
            file.setCCSID(37);
        } catch (Exception e){
            e.printStackTrace();
        } finally{
            system.disconnectAllServices();
        }
    }

    public static void callRPGProgram() throws Exception {
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");
        ProgramCall pgm = new ProgramCall(system);
        String program = "/QSYS.LIB/NIKESHM1.LIB/BANKTST.PGM";
    
        if (!pgm.run(program, new com.ibm.as400.access.ProgramParameter[0])) {
            for (com.ibm.as400.access.AS400Message msg : pgm.getMessageList()) {
                System.out.println("⚠️ RPG Program Message: " + msg.getText());
            }
            throw new RuntimeException(" RPG Program BANKTST failed.");
        }
        system.disconnectAllServices();
    }

    @SuppressWarnings({"CallToPrintStackTrace", "UseSpecificCatch"})
    public static Map<String, String> readResponseFromIFS() {
        Map<String, String> result = new HashMap<>();
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");
        try {

            IFSFile file = new IFSFile(system, "/home/NIKESHM/bankOUT.xml");
            IFSFileInputStream fileInputStream = new IFSFileInputStream(file);
            InputStreamReader inputStreamReader = new InputStreamReader(fileInputStream, "Cp037");
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = builder.parse(new org.xml.sax.InputSource(inputStreamReader));
            document.getDocumentElement().normalize();

            // ResponseMesssage
            NodeList responseMessage = document.getElementsByTagName("responseMessage");
            if (responseMessage.getLength() > 0) {
                result.put("responseMessage", responseMessage.item(0).getTextContent().trim());
            } else {
                result.put("responseMessage", "⚠️ responseMessage not found");
            }

            // ResponseCode
            NodeList responseCode = document.getElementsByTagName("responseCode");
            if (responseCode.getLength() > 0) {
                result.put("responseCode", responseCode.item(0).getTextContent().trim());
            } else {
                result.put("responseCode", "⚠️ responseCode not found");
            }

            // Program Name
            NodeList pgmname = document.getElementsByTagName("pgmname");
            if (pgmname.getLength() > 0) {
                result.put("pgmname", pgmname.item(0).getTextContent().trim());
            } else {
                result.put("pgmname", "⚠️ Program Name Not Found");
            }

	        // Name
            NodeList name = document.getElementsByTagName("Name");
            if (name.getLength() > 0) {
                result.put("Name", name.item(0).getTextContent().trim());
            } else {
                result.put("Name", "⚠️ Name Not Found");
            }    
            
            // dob
            NodeList dob = document.getElementsByTagName("dob");
            if (dob.getLength() > 0) {
                result.put("dob", dob.item(0).getTextContent().trim());
            } else {
                result.put("dob", "⚠️ dob Not Found");
            }

            // Mobnbr
            NodeList Mobnbr = document.getElementsByTagName("Mobnbr");
            if (Mobnbr.getLength() > 0) {
                result.put("Mobnbr", Mobnbr.item(0).getTextContent().trim());
            } else {
                result.put("Mobnbr", "⚠️ Mobnbr Not Found");
            }

            // email
            NodeList email = document.getElementsByTagName("email");
            if (email.getLength() > 0) {
                result.put("email", email.item(0).getTextContent().trim());
            } else {
                result.put("email", "⚠️ email Not Found");
            }

            // gender
            NodeList gender = document.getElementsByTagName("gender");
            if (gender.getLength() > 0) {
                result.put("gender", gender.item(0).getTextContent().trim());
            } else {
                result.put("gender", "⚠️ Gender Not Found");
            }

            // address1
            NodeList address1 = document.getElementsByTagName("address1");
            if (address1.getLength() > 0) {
                result.put("address1", address1.item(0).getTextContent().trim());
            } else {
                result.put("address1", "⚠️ address1 Not Found");
            }

            // address2
            NodeList address2 = document.getElementsByTagName("address2");
            if (address2.getLength() > 0) {
                result.put("address2", address2.item(0).getTextContent().trim());
            } else {
                result.put("address2", "⚠️ address2 Not Found");
            }

            // address3
            NodeList address3 = document.getElementsByTagName("address3");
            if (address3.getLength() > 0) {
                result.put("address3", address3.item(0).getTextContent().trim());
            } else {
                result.put("address3", "⚠️ address3 Not Found");
            }

            // pincode
            NodeList pincode = document.getElementsByTagName("pincode");
            if (pincode.getLength() > 0) {
                result.put("pincode", pincode.item(0).getTextContent().trim());
            } else {
                result.put("pincode", "⚠️ pincode Not Found");
            }

            // city
            NodeList city = document.getElementsByTagName("city");
            if (city.getLength() > 0) {
                result.put("city", city.item(0).getTextContent().trim());
            } else {
                result.put("city", "⚠️ city Not Found");
            }

            // state
            NodeList state = document.getElementsByTagName("state");
            if (state.getLength() > 0) {
                result.put("state", state.item(0).getTextContent().trim());
            } else {
                result.put("state", "⚠️ state Not Found");
            }

            // country
            NodeList country = document.getElementsByTagName("country");
            if (country.getLength() > 0) {
                result.put("country", country.item(0).getTextContent().trim());
            } else {
                result.put("country", "⚠️ country Not Found");
            }

            // accType
            NodeList accType = document.getElementsByTagName("accType");
            if (accType.getLength() > 0) {
                result.put("accType", accType.item(0).getTextContent().trim());
            } else {
                result.put("accType", "⚠️ accType Not Found");
            }

            // currency
            NodeList currency = document.getElementsByTagName("currency");
            if (currency.getLength() > 0) {
                result.put("currency", currency.item(0).getTextContent().trim());
            } else {
                result.put("currency", "⚠️ currency Not Found");
            }

            // idType
            NodeList idType = document.getElementsByTagName("idType");
            if (idType.getLength() > 0) {
                result.put("idType", idType.item(0).getTextContent().trim());
            } else {
                result.put("idType", "⚠️ idType Not Found");
            }

            // idNumber
            NodeList idNumber = document.getElementsByTagName("idNumber");
            if (idNumber.getLength() > 0) {
                result.put("idNumber", idNumber.item(0).getTextContent().trim());
            } else {
                result.put("idNumber", "⚠️ idNumber Not Found");
            }

        } catch (Exception e) {
            System.err.println("❌ Error reading or parsing XML: " + e.getMessage());
            e.printStackTrace();
            result.put("responseMessage", "Error");
            result.put("responseCode", "Error");
        } finally {
            system.disconnectAllServices();
        }
        return result;
    }
}