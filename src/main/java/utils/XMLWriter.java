package utils;

import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import com.ibm.as400.access.*;

public class XMLWriter {

    private static final String BASE_DIR = "/home/NIKESHM/";
    private static final String IN_PREFIX = "bankInp_";
    private static final String OUT_PREFIX = "bankOUT_";
    private static final String EXT = ".xml";

    // -------------------------------
    // THREAD-SAFE XML CREATION
    // -------------------------------
    public static synchronized String writeOrderToIFS(String xmlData) throws Exception {

        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");
        int counter = 1;
        String ifsPath;

        try {
            while (true) {
                ifsPath = BASE_DIR + IN_PREFIX + counter + EXT;
                IFSFile file = new IFSFile(system, ifsPath);

                // Try to create file exclusively
                if (!file.exists()) {
                    try (Writer writer = new OutputStreamWriter(
                            new IFSFileOutputStream(
                                    file,
                                    IFSFileOutputStream.SHARE_NONE, // EXCLUSIVE LOCK
                                    false),
                            "Cp037")) {

                        writer.write(xmlData);
                        writer.flush();
                        file.setCCSID(37);
                        return ifsPath;
                    }
                }
                counter++;
            }
        } finally {
            system.disconnectAllServices();
        }
    }

    // -------------------------------
    // CALL RPG
    // -------------------------------
    public static void callRPGProgram(String inputXmlPath) throws Exception {

        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");
        ProgramCall pgm = new ProgramCall(system);

        ProgramParameter[] params = new ProgramParameter[] {
            new ProgramParameter(inputXmlPath.getBytes("Cp037"))
        };

        if (!pgm.run("/QSYS.LIB/NIKESHM1.LIB/BANKTST.PGM", params)) {
            for (AS400Message msg : pgm.getMessageList()) {
                System.out.println(msg.getText());
            }
            throw new RuntimeException("BANKTST failed");
        }

        system.disconnectAllServices();
    }

    // -------------------------------
    // READ RESPONSE XML
    // -------------------------------
    public static Map<String, String> readResponseFromIFS(String inputXmlPath) {

        Map<String, String> result = new HashMap<>();
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");

        String outPath = inputXmlPath
                .replace(IN_PREFIX, OUT_PREFIX);

        try {
            IFSFile file = new IFSFile(system, outPath);
            IFSFileInputStream in = new IFSFileInputStream(file);

            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(in);
            doc.getDocumentElement().normalize();

            String[] fields = { "responseMessage", "responseCode" };

            for (String f : fields) {
                NodeList nl = doc.getElementsByTagName(f);
                if (nl.getLength() > 0) {
                    result.put(f, nl.item(0).getTextContent().trim());
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("responseMessage", "System Error");
            result.put("responseCode", "1");
        } finally {
            system.disconnectAllServices();
        }

        return result;
    }
}