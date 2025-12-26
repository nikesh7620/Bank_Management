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

    // Writes XML to IFS with sequential filename
    public static synchronized String writeOrderToIFS(String xmlData) throws Exception {
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");

        try {
            // Determine next file number
            int nextNum = 1;
            IFSFile dir = new IFSFile(system, "/home/NIKESHM");
            IFSFile[] files = dir.listFiles();
            if (files != null) {
                for (IFSFile f : files) {
                    String name = f.getName();
                    if (name.startsWith("bankInp_") && name.endsWith(".xml")) {
                        try {
                            int num = Integer.parseInt(name.substring(8, name.length() - 4));
                            if (num >= nextNum) nextNum = num + 1;
                        } catch (NumberFormatException ignored) {}
                    }
                }
            }

            String ifsPath = "/home/NIKESHM/bankInp_" + nextNum + ".xml";
            IFSFile file = new IFSFile(system, ifsPath);

            // Write XML to IFS
            try (Writer writer = new OutputStreamWriter(new IFSFileOutputStream(file), "Cp037")) {
                writer.write(xmlData);
                writer.flush();
                file.setCCSID(37);
            }

            return ifsPath;

        } finally {
            system.disconnectAllServices();
        }
    }

    // Calls RPG program
    public static void callRPGProgram(String inputXmlPath) throws Exception {
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");
        ProgramCall pgm = new ProgramCall(system);

        String program = "/QSYS.LIB/NIKESHM1.LIB/BANKTST.PGM";

        try {
            if (!pgm.run()) {
                StringBuilder msg = new StringBuilder();
                for (com.ibm.as400.access.AS400Message m : pgm.getMessageList()) {
                    msg.append(m.getText()).append("\n");
                }
                throw new RuntimeException("BANKTST RPG program failed: " + msg.toString());
            }
        } finally {
            system.disconnectAllServices();
        }
    }

    // Reads XML response from IFS
    public static Map<String, String> readResponseFromIFS(String xmlPath) {
        Map<String, String> result = new HashMap<>();
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");

        try {
            IFSFile file = new IFSFile(system, xmlPath);
            try (InputStreamReader reader = new InputStreamReader(new IFSFileInputStream(file), "Cp037")) {
                DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                DocumentBuilder builder = factory.newDocumentBuilder();
                Document doc = builder.parse(new org.xml.sax.InputSource(reader));
                doc.getDocumentElement().normalize();

                String[] fields = { "responseMessage", "responseCode", "pgmname", "Name", "dob", "Mobnbr",
                        "email", "gender", "address1", "address2", "address3", "pincode", "city", "state",
                        "country", "accType", "currency", "idType", "idNumber" };

                for (String field : fields) {
                    NodeList nodes = doc.getElementsByTagName(field);
                    if (nodes.getLength() > 0) {
                        result.put(field, nodes.item(0).getTextContent().trim());
                    } else {
                        result.put(field, "⚠️ " + field + " Not Found");
                    }
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
