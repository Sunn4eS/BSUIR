import com.sun.org.apache.bcel.internal.generic.DCONST;

import java.io.*;
import java.util.Scanner;
public class Main {
    public static final int  MIN_NUMBER = 0;
    public static final int  MAX_NUMBER = 1000000;
    public enum ERRORS_LIST {
        CORRECT, RANGE_ERR, NUM_ERR, NOT_TXT, NOT_EXIST, NOT_READABLE, NOT_WRITEABLE, FILE_EMPTY
    }
    public static final String[]
            ERRORS = {
            "", "Значение не попадает в диапазон!", "Проверьте корректность ввода данных!", "Расширение не txt!", "Проверьте корректность ввода пути к файлу!", "Файл закрыт для чтения!", "Файл закрыт для записи!", "Файл пуст!" };
    public static Scanner scanConsole = new Scanner(System.in);
    public static File file;
    public static void printTask() {
        System.out.println("Данная программа переводит числа из 10 с/с в 16 с/с: \n");
    }
    public static void printError (ERRORS_LIST error) {
        System.out.println(ERRORS[error.ordinal()] + "\nПовторите попытку: ");
    }
    public static ERRORS_LIST checkArea(int num, final int MIN, final int MAX) {
        ERRORS_LIST error;
        error = ERRORS_LIST.CORRECT;
        if (num < MIN || num > MAX)
            error = ERRORS_LIST.RANGE_ERR;
        return error;
    }
    public  static int checkNum(int MIN, int MAX) {
        ERRORS_LIST error;
        int num;
        num= 0;
        do {
            error = ERRORS_LIST.CORRECT;
            try {
                num = Integer.parseInt(scanConsole.nextLine());
            } catch (NumberFormatException e) {
                error = ERRORS_LIST.NUM_ERR;
            }
            if (error == ERRORS_LIST.CORRECT)
                error = checkArea(num, MIN, MAX);
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
        } while (error != ERRORS_LIST.CORRECT);
        return num;
    }
    public static boolean checkInOut() {
        final int FILE_CHOICE = 1;
        final int CONSOLE_CHOICE = 2;
        int num;
        boolean choose;
        choose = false;
        num = checkNum(FILE_CHOICE, CONSOLE_CHOICE);
        if (num == 1)
            choose = true;
        return choose;
    }
    public static boolean chooseFileInput() {
        boolean choose;
        choose= true;
        System.out.println("Вы хотите вводить число через файл? (Да - " + 1 + " / Нет - " + 2 + ")");
        choose = checkInOut();
        return choose;
    }
    public static String ReadPath(){
        ERRORS_LIST error;
        String pathToFile;
        pathToFile = " ";
        scanConsole = new Scanner(System.in);
        do {
            error = ERRORS_LIST.CORRECT;
            System.out.print("Введите путь к файлу с расширением .txt: ");
            pathToFile = scanConsole.nextLine();
            if (!pathToFile.endsWith(".txt"))
                error = ERRORS_LIST.NOT_TXT;
            if (error != ERRORS_LIST.CORRECT) {
                printError(error);
            }
        } while (error != ERRORS_LIST.CORRECT);
        return pathToFile;
    }
    public static void fileReading () {
        ERRORS_LIST error;
        String pathToFile;
        pathToFile = "";
        do {
            pathToFile = ReadPath();
            error = ERRORS_LIST.CORRECT;
            file = new File(pathToFile);
            if (!(file.exists()))
                error = ERRORS_LIST.NOT_EXIST;
            else {
                if (!file.canRead())
                    error = ERRORS_LIST.NOT_READABLE;
                else {
                    try (Scanner fileScanner = new Scanner(file)){
                        if (!fileScanner.hasNext())
                            error = ERRORS_LIST.FILE_EMPTY;
                    } catch (FileNotFoundException e) {
                        printError(error);
                    }
                }
            }
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
        } while (error != ERRORS_LIST.CORRECT);
    }
    public static String fileWriting() {
        ERRORS_LIST error;
        String pathToFile;
        pathToFile = "";
        do {
            pathToFile = ReadPath();
            error = ERRORS_LIST.CORRECT;

            if (!(new File(pathToFile)).exists())
                error = ERRORS_LIST.NOT_EXIST;
            else {
                File file = new File(pathToFile);
                if (!file.canWrite())
                    error = ERRORS_LIST.NOT_WRITEABLE;
            }
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
        } while (error != ERRORS_LIST.CORRECT);
        return pathToFile;
    }
    public static int readDecFile() {
        int decNum;
        decNum = 0;
        ERRORS_LIST error;
        error = ERRORS_LIST.CORRECT;
        do {
            fileReading();
            try (Scanner scanFile = new Scanner(file)) {
                decNum = scanFile.nextInt();
                error = checkArea(decNum, MIN_NUMBER, MAX_NUMBER);
            }
            catch (Exception e) {
                error = ERRORS_LIST.NUM_ERR;
            }
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
        } while (error != ERRORS_LIST.CORRECT);
        return decNum;
    }
    public static int readDec() {
        boolean fromFile;
        int decNum;
        decNum = 0;
        fromFile = chooseFileInput();
        if (fromFile)
            decNum = readDecFile();
        else {
            System.out.print("Введите число [" + MIN_NUMBER + ":" + MAX_NUMBER + "] ");
            decNum = checkNum(MIN_NUMBER, MAX_NUMBER);
        }
        return decNum;
    }
    public static String decToHex(int decNum) {
        String hexNum;
        int modFromDec;
        final char[] hexCharList = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        hexNum = "";
        modFromDec = 0;
        while (decNum > 0) {
            modFromDec = decNum % 16;
            hexNum = hexCharList[modFromDec] + hexNum;
            decNum /= 16;
        }
        return hexNum;
    }
    public static boolean chooseFileOutput() {
        boolean choose;
        System.out.println("Вы хотите выводить ответ через файл? (Да - " + 1 + " / Нет - " + 2 + ")");
        choose = checkInOut();
        return choose;
    }
    public static void printResult(String hexNum) {
        String pathToFile;
        boolean printToFile;
        ERRORS_LIST error;
        printToFile = chooseFileOutput();
        pathToFile = "";
        error = ERRORS_LIST.CORRECT;
        if (printToFile) {
            pathToFile = fileWriting();
            try (FileWriter fileWriter = new FileWriter(pathToFile, true)){
                fileWriter.write("Число в 16с/c: ");
                fileWriter.write(hexNum);
            } catch (IOException e) {
                error = ERRORS_LIST.NOT_WRITEABLE;
                printError(error);
            };
        } else {
            System.out.print("Число в 16с/c: ");
            System.out.print(hexNum);
        }
    }
    public static void main(String[] args) {
        int decNum;
        String hexNum;
        printTask();
        decNum = readDec();
        hexNum = decToHex(decNum);
        printResult(hexNum);
        scanConsole.close();
    }
}
