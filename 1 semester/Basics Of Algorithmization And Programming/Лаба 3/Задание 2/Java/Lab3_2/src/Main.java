import java.io.*;
import java.util.Scanner;
import java.util.Set;
import java.util.HashSet;
public class Main {
    public static final int  MIN_NUMBER = 2;
    public static final int  MAX_NUMBER = 10000;
    public enum ERRORS_LIST {
        CORRECT, RANGE_ERR, NUM_ERR, NOT_TXT, NOT_EXIST, NOT_READABLE, NOT_WRITEABLE, FILE_EMPTY
    }
    public static final String[]
            ERRORS = {
            "", "Значение не попадает в диапазон!", "Проверьте корректность ввода данных!", "Расширение не txt!", "Проверьте корректность ввода пути к файлу!", "Файл закрыт для чтения!", "Файл закрыт для записи!", "Файл пуст!" };
    public static Scanner scanConsole = new Scanner(System.in);
    public static File file;
    public static void printTask() {
        System.out.println("Данная программа ищет все простые числа до числа P:\n");
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
        num = 0;
        do {
            error = ERRORS_LIST.CORRECT;
            try {
                num = scanConsole.nextInt();
                scanConsole.nextLine();
            } catch (NumberFormatException e) {
                error = ERRORS_LIST.NUM_ERR;
            }
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
        boolean choose = true;
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
        pathToFile= "";
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
    public static int readSetFile() {
        int num;
        ERRORS_LIST error;
        num = 0;
        error = ERRORS_LIST.CORRECT;
        do {
            fileReading();
            try (Scanner scanFile = new Scanner(file)) {
                num = scanFile.nextInt();
                error = checkArea(num, MIN_NUMBER, MAX_NUMBER);
            }
            catch (Exception e) {
                error = ERRORS_LIST.NUM_ERR;
            }
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
        } while (error != ERRORS_LIST.CORRECT);
        return num;
    }
    public static Set<Integer> readSet() {
        boolean fromFile;
        Set<Integer> numbers = new HashSet<>();
        int num;
        num = 0;
        fromFile = chooseFileInput();
        if (!fromFile) {
            System.out.print("Введите число до которого вы хотетие найти простые числа [" + MIN_NUMBER + ":" + MAX_NUMBER + "] ");
            num = checkNum(MIN_NUMBER, MAX_NUMBER);
        }
        else
            num = readSetFile();
        for (int i = 2; i <= num; ++i)
            numbers.add(i);
        return  numbers;
    }
    public static Set<Integer> sortSet(final Set<Integer> primeNumbers) {
        int prime;
        int length;
        prime = MIN_NUMBER;
        length = primeNumbers.size() + 1;
        while (prime * prime <= length) {
            if (primeNumbers.contains(prime))
                for (int i = 2 * prime; i <= length; i += prime)
                    primeNumbers.remove(i);
            prime++;
        }
        return primeNumbers;
    }
    public static boolean chooseFileOutput() {
        boolean choose;
        System.out.println("Вы хотите выводить матрицу через файл? (Да - " + 1 + " / Нет - " + 2 + ")");
        choose = checkInOut();
        return choose;
    }
    public static void printResult(Set<Integer> primeNumbers) {

        String pathToFile;
        boolean printToFile;

        printToFile = chooseFileOutput();
        pathToFile = "";
            if (printToFile) {
                pathToFile = fileWriting();
                try (FileWriter fileWriter = new FileWriter(pathToFile, true)){
                    fileWriter.write("Множество простых чисел:");
                } catch (IOException e) {

                };

            } else {
                System.out.println("Множество простых чисел:");
            }
            for (int num : primeNumbers) {
                if (printToFile) {
                    try (FileWriter fileWriter = new FileWriter(pathToFile, true)){
                        fileWriter.write(num + " ");
                    } catch (IOException e) {}
                } else
                    System.out.print(num + " ");
            }
    }
    public static void main(String[] args) {
        Set<Integer> primeNumbers = new HashSet<>();
        printTask();
        primeNumbers = readSet();
        primeNumbers = sortSet(primeNumbers);
        printResult(primeNumbers);
        scanConsole.close();
    }
}
