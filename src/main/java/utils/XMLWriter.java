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
import com.ibm.as400.access.ProgramParameter;

public class XMLWriter {

    public static void writeOrderToIFS(String xmlData, String xmlFilePath) throws Exception {
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");
        IFSFile file = new IFSFile(system, xmlFilePath);

        try (Writer writer = new OutputStreamWriter(
                new IFSFileOutputStream(file, IFSFileOutputStream.SHARE_ALL, false),
                "Cp037")) {
            writer.write(xmlData);
            writer.flush();
            file.setCCSID(37);
        } finally {
            system.disconnectAllServices();
        }
    }

    public static void callRPGProgram(String xmlFilePath, String responseFilePath) throws Exception {
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");
        ProgramCall pgm = new ProgramCall(system);

        String program = "/QSYS.LIB/NIKESHM1.LIB/BANKTST.PGM";
        ProgramParameter[] params = new ProgramParameter[2];
        params[0] = new ProgramParameter((xmlFilePath + "\0").getBytes("Cp037"));
        params[1] = new ProgramParameter((responseFilePath + "\0").getBytes("Cp037"));

        pgm.setProgram(program, params);

        if (!pgm.run()) {
            for (com.ibm.as400.access.AS400Message msg : pgm.getMessageList()) {
                System.out.println("⚠️ RPG Program Message: " + msg.getText());
            }
            throw new RuntimeException("RPG Program BANKTST failed.");
        }

        system.disconnectAllServices();
    }

    public static Map<String, String> readResponseFromIFS(String responseFilePath) {
        Map<String, String> result = new HashMap<>();
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");

        try {
            IFSFile file = new IFSFile(system, responseFilePath);
            InputStreamReader reader = new InputStreamReader(new IFSFileInputStream(file), "Cp037");

            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = builder.parse(new org.xml.sax.InputSource(reader));
            document.getDocumentElement().normalize();

            String[] fields = { "responseMessage", "responseCode", "pgmname", "Name", "dob", "Mobnbr", "email",
                    "gender", "address1", "address2", "address3", "pincode", "city", "state", "country", "accType",
                    "currency", "otherCurrency", "idType", "idNumber" };

            for (String field : fields) {
                NodeList nodeList = document.getElementsByTagName(field);
                if (nodeList.getLength() > 0) {
                    result.put(field, nodeList.item(0).getTextContent().trim());
                } else {
                    result.put(field, "");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("responseMessage", "Error");
            result.put("responseCode", "Error");
        } finally {
            system.disconnectAllServices();
        }

        return result;
    }
}
