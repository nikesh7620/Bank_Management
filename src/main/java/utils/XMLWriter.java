package utils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class XMLWriter {

    private static int fileCounter = 0;

    // Ensure unique file numbers in multi-threaded scenario
    private static synchronized int getNextFileNumber() {
        fileCounter++;
        return fileCounter;
    }

    public static String writeOrderToIFS(String xml) throws IOException {
        int fileNum = getNextFileNumber();
        String dirPath = "/home/NIKESHM/";
        File dir = new File(dirPath);
        if (!dir.exists()) {
            boolean created = dir.mkdirs();
            if (!created) {
                throw new IOException("Failed to create directory: " + dirPath);
            }
        }

        String inputFilePath = dirPath + "bankInp" + fileNum + ".xml";
        File xmlFile = new File(inputFilePath);

        try (FileWriter writer = new FileWriter(xmlFile)) {
            writer.write(xml);
        }

        // Ensure file was created
        if (!xmlFile.exists() || xmlFile.length() == 0) {
            throw new IOException("Failed to create/write XML file: " + inputFilePath);
        }

        return inputFilePath;
    }

    public static void callRPGProgram() {
        // Placeholder: actual RPG call logic goes here
    }

    public static Map<String, String> readResponseFromIFS(String inputFilePath) {
        Map<String, String> response = new HashMap<>();
        // Replace "bankInp" with "bankOut" to simulate response file
        String outputFilePath = inputFilePath.replace("bankInp", "bankOut");

        // Dummy response for now
        response.put("responseMessage", "✓ Success");
        response.put("responseCode", "1");

        return response;
    }
}
