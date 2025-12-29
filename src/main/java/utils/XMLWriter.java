package utils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class XMLWriter {

    private static int fileCounter = 0;

    // Synchronized method to ensure unique file numbers for multiple users
    private static synchronized int getNextFileNumber() {
        fileCounter++;
        return fileCounter;
    }

    public static String writeOrderToIFS(String xml) throws IOException {
        int fileNum = getNextFileNumber();
        String inputFilePath = "/home/NIKESHM/bankInp" + fileNum + ".xml";

        try (FileWriter writer = new FileWriter(new File(inputFilePath))) {
            writer.write(xml);
        }

        return inputFilePath;
    }

    public static void callRPGProgram() {
        // Placeholder for RPG program call
        // The RPG program will process the input XML file
    }

    public static Map<String, String> readResponseFromIFS() throws IOException {
        Map<String, String> response = new HashMap<>();
        int fileNum = fileCounter; // Latest file number

        String outputFilePath = "/home/NIKESHM/bankOut" + fileNum + ".xml";

        // Dummy response reading logic
        // In real code, read the XML from outputFilePath and parse response
        response.put("responseMessage", "✓ Success");
        response.put("responseCode", "1");

        return response;
    }
}
