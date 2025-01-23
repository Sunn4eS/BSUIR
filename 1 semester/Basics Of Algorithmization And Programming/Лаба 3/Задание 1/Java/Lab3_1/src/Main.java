import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Scanner;
import java.io.File;
import java.io.BufferedWriter;
import java.io.OutputStreamWriter;
public class Main {
    public static final int MIN_LENGTH = 1;
    public static final int MAX_LENGTH = 1000;
    static Scanner scanConsole = new Scanner(System.in);
    static File file;
    public static void printTask() {
        System.out.println("Данная программа находит место последнего вхождения первой строки во вторую:\n");
    }
    public static boolean chooseFileInput() {
        int isFileInput;
        boolean isCorrect, choose;
        isFileInput = 0;
        choose = true;
        do {
            System.out.println("Вы хотите вводить строки через файл? (Да - " + 1 + " / Нет - " + 0 + ")");
            isCorrect = true;
            try {
                isFileInput = Integer.parseInt(scanConsole.nextLine());
            } catch (NumberFormatException e) {
                System.out.println("Некорректный выбор!");
                isCorrect = false;
            }
            if (isCorrect) {
                if (isFileInput == 1)
                    choose = true;
                else if (isFileInput == 0)
                    choose = false;
                else {
                    isCorrect = false;
                    System.out.println("Некорректный выбор!");
                }
            }
        } while (!isCorrect);
        return choose;
    }
    public static boolean checkLength(String str) {
        boolean isCorrect;
        isCorrect = true;
        if (str.isEmpty() || str.length() > MAX_LENGTH) {
            System.out.println("Значение не попадает в диапазон!");
            isCorrect = false;
        }
        return isCorrect;
    }
    public static String readPathFile() {
        boolean isCorrect;
        String pathToFile;
        isCorrect = true;
        pathToFile = " ";
        do {
            System.out.println("Введите путь к файлу с расширением .txt: ");
            pathToFile = scanConsole.nextLine();
            if ((pathToFile.length() < 5) && (pathToFile.charAt(pathToFile.length() - 4) != '.') && (pathToFile.charAt(pathToFile.length() - 3) != 't') && (pathToFile.charAt(pathToFile.length() - 2) != 'x') && (pathToFile.charAt(pathToFile.length() - 1) != 't')) {
                isCorrect = false;
                System.out.println("Расширение файла не .txt!");
            }
        } while (!isCorrect);
        return pathToFile;
    }
    public static boolean isExists() {
        boolean isCorrect;
        isCorrect = false;
        if (file.exists())
            isCorrect = true;
        return isCorrect;
    }
    public static boolean isAbleToReading() {
        boolean isCorrect;
        isCorrect = false;
        if (file.canRead())
            isCorrect = true;
        return isCorrect;
    }
    public static boolean isAbleToWriting() {
        boolean isCorrect;
        isCorrect = false;
        if (file.canWrite())
            isCorrect = true;
        return isCorrect;
    }
    public static boolean isEmpty() {
        boolean isCorrect;
        isCorrect = false;
        if (file.length() == 0)
            isCorrect = true;
        return isCorrect;
    }

    public static boolean isRightFileString() {
        boolean isCorrect;
        isCorrect = false;
        try (Scanner scanFile = new Scanner(file)) {
            scanFile.nextLine();
            if (!scanFile.hasNext())
                isCorrect = true;
            scanFile.nextLine();
            if (!scanFile.hasNext())
                isCorrect = true;
          } catch (Exception e) {}
        return isCorrect;
    }
    public static void getFileNormalReading() {
        boolean isCorrect;
        do {
            isCorrect = true;
            file = new File(readPathFile());
            if (!isExists()) {
                isCorrect = false;
                System.out.println("Проверьте корректность ввода пути к файлу!\n");
            }
            if (isCorrect && !isAbleToReading()) {
                isCorrect = false;
                System.out.println("Файл закрыт для чтения!\n");
            }
            if (isCorrect && isEmpty()) {
                isCorrect = false;
                System.out.println("Файл пуст!\n");
            }
            if (isCorrect && !isRightFileString()) {
                isCorrect = false;
                System.out.println("Количество строк не совпадает с условием!\n");
            }
        } while (!isCorrect);
    }
    public static void getFileNormalWriting() {
        boolean isCorrect;
        do {
            file = new File(readPathFile());
            isCorrect = true;
            if (!isExists()) {
                isCorrect = false;
                System.out.println("Проверьте корректность ввода пути к файлу!");
            }
            if (isCorrect && !isAbleToWriting()) {
                isCorrect = false;
                System.out.println("Файл закрыт для записи!");
            }
        } while (!isCorrect);
    }
    public static String readFileString(Scanner scanFile) {
        String str;
        str = scanFile.nextLine();
        return str;
    }
    public static String readConsoleString(int num) {
        boolean isCorrect;
        String str;
        str = "";
        do {
            isCorrect = true;
            System.out.println("Введите строку номер " + num + " [" + MIN_LENGTH + ":" + MAX_LENGTH + "]: ");
            str = scanConsole.nextLine();
            isCorrect = checkLength(str);
        } while (!isCorrect);
        return str;
    }
    public static String[] readString() {
        String[] strings = new String[2];
        boolean isCorrect;
        do {
            isCorrect = true;
            if (chooseFileInput()) {
                getFileNormalReading();
                try (Scanner scanFile = new Scanner(file)) {
                    strings[0] = readFileString(scanFile);
                    strings[1] = readFileString(scanFile);
                } catch (Exception e) {
                }
            } else {
                strings[0] = readConsoleString(1);
                strings[1] = readConsoleString(2);
            }
            if (strings[0].length() > strings[1].length()) {
                isCorrect = false;
                System.out.println("Длинна не соответсвует условию!\n");
            }
        }while (!isCorrect);
        return strings;
    }
    public static int findLastOccurrence(String str1, String str2) {
        int lengthOfStr1;
        int lengthOfStr2;
        int indOfStr1;
        int indOfStr2;
        int place;
        boolean endOfStr1;


        lengthOfStr1 = str1.length();
        lengthOfStr2 = str2.length();
        place = 0;
        indOfStr1 = 0;
        indOfStr2 = 0;
        endOfStr1 = false;
        while ((lengthOfStr2 > 0) && (place == 0))
        {
            if (str1.charAt(lengthOfStr1 - 1) == str2.charAt(lengthOfStr2 - 1))
            {
                indOfStr1 = lengthOfStr1 - 1;
                indOfStr2 = lengthOfStr2 - 1;
                endOfStr1 = false;
                while ((indOfStr1 > 0) && (indOfStr2 > 0) && (str1.charAt(indOfStr1) == str2.charAt(indOfStr2)))
                {
                    indOfStr1--;
                    indOfStr2--;
                }
                if (indOfStr1 != 0)
                    endOfStr1 = true;
                if (!endOfStr1)
                    place = indOfStr2 + 1;
            }
            lengthOfStr2--;
        }
        return place;
    }
    public static boolean chooseFileOutput() {
        int isFileOutput;
        boolean isCorrect, choose;
        isFileOutput = 0;
        choose = true;
        do {
            System.out.println("Вы хотите выводить результат через файл? (Да - " + 1 + " / Нет - " + 0 + ")");
            isCorrect = true;
            try {
                isFileOutput = Integer.parseInt(scanConsole.nextLine());
            } catch (NumberFormatException e) {
                System.out.println("Некорректный выбор!");
                isCorrect = false;
            }
            if (isCorrect) {
                if (isFileOutput == 1)
                    choose = true;
                else if (isFileOutput == 0)
                    choose = false;
                else {
                    isCorrect = false;
                    System.out.println("Некорректный выбор!");
                }
            }
        } while (!isCorrect);
        return choose;
    }
    public static void printConsoleResult(int place) {
            System.out.print("Номер позиции последнего вхождения строки st1 в строку st2 = " + place);
    }
    public static void printFileResult(int place) {
        try (BufferedWriter writer = new BufferedWriter(
                new OutputStreamWriter(Files.newOutputStream(file.toPath()), StandardCharsets.UTF_8))) {
            writer.write("Номер позиции последнего вхождения строки st1 в строку st2 = " + place);
        } catch (Exception e) {}
    }
    public static void printResult(int place) {
        if (chooseFileOutput()) {
            getFileNormalWriting();
            printFileResult(place);
        }
        else
            printConsoleResult(place);
    }
    public static void main(String[] args) {
        boolean nonGrowing;
        String str1;
        String str2;
        String[] strings;
        int place;
        printTask();
        strings = readString();
        str1 = strings[0];
        str2 = strings[1];
        place = findLastOccurrence(str1, str2);
        printResult(place);
        scanConsole.close();
    }
}
