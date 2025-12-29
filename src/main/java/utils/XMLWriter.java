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

    private static final String AS400_HOST = "PUB400.COM";
    private static final String AS400_USER = "NIKESHM";
    private static final String AS400_PASS = "zoro@404";
    private static final String IFS_DIR = "/home/NIKESHM/";

    /**
     * Writes XML data to AS400 IFS with a dynamic file name like bankInp1.xml, bankInp2.xml...
     * Returns the full path of the created XML file.
     */
    @SuppressWarnings("CallToPrintStackTrace")
    public static String writeOrderToIFS(String xmlData) throws Exception {
        AS400 system = new AS400(AS400_HOST, AS400_USER, AS400_PASS);
        try {
            int fileIndex = 1;
            String filePath;

            // Find the next available file name
            while (true) {
                filePath = IFS_DIR + "bankInp" + fileIndex + ".xml";
                IFSFile file = new IFSFile(system, filePath);
                if (!file.exists()) break; // file available
                fileIndex++;
            }

            IFSFile file = new IFSFile(system, filePath);

            try (Writer writer = new OutputStreamWriter(
                    new IFSFileOutputStream(file, IFSFileOutputStream.SHARE_ALL, false),
                    "Cp037")) {
                writer.write(xmlData);
                writer.flush();
                file.setCCSID(37);
            }

            return filePath;
        } finally {
            system.disconnectAllServices();
        }
    }

    /**
     * Calls the RPG program on AS400
     */
    public static void callRPGProgram(String programPath) throws Exception {
        AS400 system = new AS400(AS400_HOST, AS400_USER, AS400_PASS);
        ProgramCall pgm = new ProgramCall(system);
        pgm.setProgram(programPath);

        if (!pgm.run()) {
            for (com.ibm.as400.access.AS400Message msg : pgm.getMessageList()) {
                System.out.println("⚠️ RPG Program Message: " + msg.getText());
            }
            throw new RuntimeException("RPG Program failed.");
        }

        system.disconnectAllServices();
    }

    /**
     * Reads the response XML from IFS and returns it as a Map
     * @param fileName Name of output XML (e.g., bankOut1.xml)
     */
    @SuppressWarnings({"CallToPrintStackTrace", "UseSpecificCatch"})
    public static Map<String, String> readResponseFromIFS(String fileName) {
        Map<String, String> result = new HashMap<>();
        AS400 system = new AS400(AS400_HOST, AS400_USER, AS400_PASS);

        try {
            IFSFile file = new IFSFile(system, IFS_DIR + fileName);
            if (!file.exists()) {
                result.put("responseMessage", "✖ Response file not found");
                result.put("responseCode", "0");
                return result;
            }

            IFSFileInputStream fileInputStream = new IFSFileInputStream(file);
            InputStreamReader reader = new InputStreamReader(fileInputStream, "Cp037");

            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(new org.xml.sax.InputSource(reader));
            doc.getDocumentElement().normalize();

            NodeList responseMessage = doc.getElementsByTagName("responseMessage");
            result.put("responseMessage", responseMessage.getLength() > 0 ? responseMessage.item(0).getTextContent().trim() : "⚠️ responseMessage not found");

            NodeList responseCode = doc.getElementsByTagName("responseCode");
            result.put("responseCode", responseCode.getLength() > 0 ? responseCode.item(0).getTextContent().trim() : "⚠️ responseCode not found");

        } catch (Exception e) {
            e.printStackTrace();
            result.put("responseMessage", "✖ Error reading XML: " + e.getMessage());
            result.put("responseCode", "0");
        } finally {
            system.disconnectAllServices();
        }

        return result;
    }
}
