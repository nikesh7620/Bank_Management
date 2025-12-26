package utils;

import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;
import java.util.Arrays;
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

    // Writes XML to a sequential IFS path and returns the path
    public static String writeOrderToIFS(String xmlData) throws Exception {
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");

        try {
            String dirPath = "/home/NIKESHM";
            IFSFile dir = new IFSFile(system, dirPath);

            // List existing bankInp_*.xml files
            IFSFile[] files = dir.listFiles((f) -> f.getName().startsWith("bankInp_") && f.getName().endsWith(".xml"));
            
            // Find the highest existing number
            int nextIndex = 1;
            if (files != null && files.length > 0) {
                nextIndex = Arrays.stream(files)
                        .map(f -> f.getName().replace("bankInp_", "").replace(".xml", ""))
                        .mapToInt(Integer::parseInt)
                        .max()
                        .getAsInt() + 1;
            }

            String ifsPath = dirPath + "/bankInp_" + nextIndex + ".xml";
            IFSFile file = new IFSFile(system, ifsPath);

            try (Writer writer = new OutputStreamWriter(
                    new IFSFileOutputStream(file, IFSFileOutputStream.SHARE_ALL, false),
                    "Cp037")) {
                writer.write(xmlData);
                writer.flush();
                file.setCCSID(37);
            }

            return ifsPath;
        } finally {
            system.disconnectAllServices();
        }
    }

    // Calls RPG program (assuming it processes a given input XML)
    public static void callRPGProgram(String inputXmlPath) throws Exception {
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");
        try {
            ProgramCall pgm = new ProgramCall(system);
            String program = "/QSYS.LIB/NIKESHM1.LIB/BANKTST.PGM";

            // Pass the input XML path to RPG program as parameter (if needed)
            if (!pgm.run(program, new com.ibm.as400.access.ProgramParameter[0])) {
                for (com.ibm.as400.access.AS400Message msg : pgm.getMessageList()) {
                    System.out.println("⚠️ RPG Program Message: " + msg.getText());
                }
                throw new RuntimeException("RPG Program BANKTST failed.");
            }
        } finally {
            system.disconnectAllServices();
        }
    }

    // Reads XML response from a given IFS path
    public static Map<String, String> readResponseFromIFS(String xmlPath) {
        Map<String, String> result = new HashMap<>();
        AS400 system = new AS400("PUB400.COM", "NIKESHM", "zoro@404");

        try {
            IFSFile file = new IFSFile(system, xmlPath);
            IFSFileInputStream fileInputStream = new IFSFileInputStream(file);
            InputStreamReader inputStreamReader = new InputStreamReader(fileInputStream, "Cp037");

            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = builder.parse(new org.xml.sax.InputSource(inputStreamReader));
            document.getDocumentElement().normalize();

            // Read fields
            String[] fields = { "responseMessage", "responseCode", "pgmname", "Name", "dob", "Mobnbr",
                    "email", "gender", "address1", "address2", "address3", "pincode", "city", "state",
                    "country", "accType", "currency", "idType", "idNumber" };

            for (String field : fields) {
                NodeList nodeList = document.getElementsByTagName(field);
                if (nodeList.getLength() > 0) {
                    result.put(field, nodeList.item(0).getTextContent().trim());
                } else {
                    result.put(field, "⚠️ " + field + " Not Found");
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
