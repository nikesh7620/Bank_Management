package utils;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.IFSFile;
import com.ibm.as400.access.IFSFileInputStream;
import com.ibm.as400.access.IFSFileOutputStream;
import com.ibm.as400.access.ProgramCall;
import com.ibm.as400.access.ProgramParameter;

import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class XMLWriter {

    private static final String AS400_HOST = "PUB400.COM";
    private static final String AS400_USER = "NIKESHM";
    private static final String AS400_PASS = "zoro@404";
    private static final String IFS_DIR = "/home/NIKESHM/";

    /** Write XML string to AS400 IFS with dynamic filename */
    public static String writeOrderToIFS(String xmlData) throws Exception {
        AS400 system = new AS400(AS400_HOST, AS400_USER, AS400_PASS);
        try {
            int fileIndex = 1;
            String filePath;

            while (true) {
                filePath = IFS_DIR + "bankInp" + fileIndex + ".xml";
                IFSFile file = new IFSFile(system, filePath);
                if (!file.exists()) break;
                fileIndex++;
            }

            IFSFile file = new IFSFile(system, filePath);
            try (Writer writer = new OutputStreamWriter(
                    new IFSFileOutputStream(file, IFSFileOutputStream.SHARE_ALL, false), "Cp037")) {
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
     * Calls RPG program BANKTST with parameters:
     * numFiles (int), files[100] (char(256)), file[100] (char(256))
     */
    public static void callRPGProgram(List<String> inputFiles, List<String> outputFiles) throws Exception {
        if (inputFiles.size() != outputFiles.size()) {
            throw new IllegalArgumentException("Input and output files count mismatch");
        }

        AS400 system = new AS400(AS400_HOST, AS400_USER, AS400_PASS);
        try {
            ProgramCall pgm = new ProgramCall(system);

            String rpgPath = "/QSYS.LIB/NIKESHM1.LIB/BANKTST.PGM";
            pgm.setProgram(rpgPath);

            int maxFiles = 100;
            int fileNameLength = 256;

            // 1️⃣ numFiles
            byte[] numFilesParam = new byte[4];
            int num = inputFiles.size();
            numFilesParam[0] = (byte) ((num >> 24) & 0xFF);
            numFilesParam[1] = (byte) ((num >> 16) & 0xFF);
            numFilesParam[2] = (byte) ((num >> 8) & 0xFF);
            numFilesParam[3] = (byte) (num & 0xFF);

            // 2️⃣ files array (100 x 256)
            byte[] filesArray = new byte[maxFiles * fileNameLength];
            for (int i = 0; i < inputFiles.size(); i++) {
                byte[] pathBytes = inputFiles.get(i).getBytes("Cp037");
                System.arraycopy(pathBytes, 0, filesArray, i * fileNameLength, Math.min(pathBytes.length, fileNameLength - 1));
                filesArray[i * fileNameLength + pathBytes.length] = 0; // null terminator
            }

            // 3️⃣ file array (100 x 256)
            byte[] fileArray = new byte[maxFiles * fileNameLength];
            for (int i = 0; i < outputFiles.size(); i++) {
                byte[] pathBytes = outputFiles.get(i).getBytes("Cp037");
                System.arraycopy(pathBytes, 0, fileArray, i * fileNameLength, Math.min(pathBytes.length, fileNameLength - 1));
                fileArray[i * fileNameLength + pathBytes.length] = 0;
            }

            ProgramParameter[] parameters = new ProgramParameter[3];
            parameters[0] = new ProgramParameter(numFilesParam);
            parameters[1] = new ProgramParameter(filesArray);
            parameters[2] = new ProgramParameter(fileArray);

            pgm.setParameterList(parameters);

            if (!pgm.run()) {
                for (com.ibm.as400.access.AS400Message msg : pgm.getMessageList()) {
                    System.out.println("⚠️ RPG Program Message: " + msg.getText());
                }
                throw new RuntimeException("RPG Program failed");
            }

        } finally {
            system.disconnectAllServices();
        }
    }

    /** Read XML response from AS400 IFS */
    public static Map<String, String> readResponseFromIFS(String fileName) {
        Map<String, String> result = new HashMap<>();
        AS400 system = new AS400(AS400_HOST, AS400_USER, AS400_PASS);

        try {
            IFSFile file = new IFSFile(system, fileName);
            if (!file.exists()) {
                result.put("responseMessage", "✖ Response file not found");
                result.put("responseCode", "0");
                return result;
            }

            InputStreamReader reader = new InputStreamReader(new IFSFileInputStream(file), "Cp037");
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(new org.xml.sax.InputSource(reader));
            doc.getDocumentElement().normalize();

            NodeList responseMessage = doc.getElementsByTagName("responseMessage");
            NodeList responseCode = doc.getElementsByTagName("responseCode");

            result.put("responseMessage", responseMessage.getLength() > 0 ? responseMessage.item(0).getTextContent().trim() : "⚠️ responseMessage not found");
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

