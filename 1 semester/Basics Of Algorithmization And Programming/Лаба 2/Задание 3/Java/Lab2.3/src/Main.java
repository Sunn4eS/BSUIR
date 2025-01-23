import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
public class Main {
    public static final int
            MIN_MARK = 0,
            MAX_MARK = 10,
            FIRST_STUDENT = 1,
            LAST_STUDENT = 30,
            LAST_COLUMN = 10,
            FIRST_COLUMN = 1;
    static Scanner scanConsole = new Scanner(System.in);
    static Scanner scanFile;
    static File file;
    public static void printTask() {
        System.out.println("Данная программа выводит номера отличников за семестр.\n\n");
    }
    public static boolean chooseFileInput() {
        int isFileInput;
        boolean isCorrect, choose;
        isFileInput = 0;
        choose = true;
        do {
            System.out.println("Вы хотите вводить матрицу через файл? (Да - " + 1 + " / Нет - " + 0 + ")");
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
    public static boolean checkArea(int num, final int MIN, final int MAX) {
        boolean isCorrect;
        isCorrect = true;
        if (num < MIN || num > MAX) {
            System.out.println("Значение не попадает в диапазон!\n");
            isCorrect = false;
        }
        return isCorrect;
    }
    public static String readPathFile() {
        boolean isCorrect;
        int len;
        String pathToFile;
        isCorrect = false;
        len = 0;
        pathToFile = "";
        do {
            System.out.println("Введите путь к файлу с расширением .txt с матрицей, у которой разряд не должен превышать , а её натуральные элементы должны лежать в пределе: ");
            pathToFile = scanConsole.nextLine();
            len = pathToFile.length();
            if (len > 4 && pathToFile.substring(len - 4).equals(".txt"))
                isCorrect = true;
            else
            {
                isCorrect = false;
                System.out.println("Расширение файла не .txt!");
            }
        } while (!isCorrect);
        return pathToFile;
    }
    public static boolean isExists(String pathToFile) {
        boolean isCorrect;
        isCorrect = false;
        file = new File(pathToFile);
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

    public static boolean isRightFileNums() {
        int mark;
        boolean isCorrect;
        isCorrect = true;
        mark = 0;
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        try {
            mark = scanFile.nextInt();
        } catch (NumberFormatException e) {
            System.out.println("Некорректный тип данных внутри файла!");
            isCorrect = false;
        }

        if (isCorrect)
            isCorrect = checkArea(mark, MIN_MARK, MAX_MARK);
        scanFile.nextLine();
        while (isCorrect && scanFile.hasNextInt()) {
            try {
                mark = scanFile.nextInt();
            } catch (NumberFormatException e) {
                System.out.println("Некорректный тип данных внутри файла!");
                isCorrect = false;
            }
            if (isCorrect)
                isCorrect = checkArea(mark, MIN_MARK, MAX_MARK);
        }
        scanFile.close();
        return isCorrect;
    }

    public static void getFileNormalReading() {
        boolean isCorrect;
        String pathToFile;
        pathToFile = "";
        do {
            isCorrect = true;
            pathToFile = readPathFile();
            if (!isExists(pathToFile)) {
                isCorrect = false;
                System.out.println("Проверьте корректность ввода пути к файлу!");
            }
            if (isCorrect && !isAbleToReading()) {
                isCorrect = false;
                System.out.println("Файл закрыт для чтения!");
            }
            if (isCorrect && !isAbleToWriting()) {
                isCorrect = false;
                System.out.println("Файл закрыт для записи!");
            }
            if (isCorrect && isEmpty()) {
                isCorrect = false;
                System.out.println("Файл пуст!");
            }
            if (isCorrect && !isRightFileNums()) {
                isCorrect = false;
                System.out.println("Некорректный тип данных внутри файла!");
            }
        } while (!isCorrect);

    }
    public static void getFileNormalWriting() {
        boolean isCorrect;
        String pathToFile;
        pathToFile = "";
        do {
            isCorrect = true;
            pathToFile = readPathFile();
            if (!isExists(pathToFile)) {
                isCorrect = false;
                System.out.println("Проверьте корректность ввода пути к файлу!");
            }
            if (isCorrect && !isAbleToWriting()) {
                isCorrect = false;
                System.out.println("Файл закрыт для записи!");
            }
        } while (!isCorrect);
    }
    public static int[][] readFileMatrix() {
        int[][] matrix;
        matrix = new int[LAST_STUDENT][LAST_COLUMN];
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}

        for (int row = 0; row < LAST_STUDENT; row++)
            for (int col = 0; col < LAST_COLUMN; col++)
                matrix[row][col] = scanFile.nextInt();
        scanFile.close();
        return matrix;
    }

    public static int[][] readConsoleMatrix() {
        int[][] matrix;
        boolean isCorrect;
        matrix = new int[LAST_STUDENT][LAST_COLUMN];
        for (int row = 0; row < LAST_STUDENT; row++)
            for (int col = 0; col < LAST_COLUMN; col++)
                do {
                    System.out.print("Введите оценку " + (row + 1) + " человека за " + (col + 1) + " за " );
                    isCorrect = true;
                    try {
                        matrix[row][col] = Integer.parseInt(scanConsole.nextLine());
                    } catch (NumberFormatException e) {
                        System.out.println("Проверьте корректность ввода данных!");
                        isCorrect = false;
                    }
                    if (isCorrect)
                        isCorrect = checkArea(matrix[row][col], MIN_MARK, MAX_MARK);
                } while (!isCorrect);
        return matrix;
    }

    public static int[][] readMatrix() {
        int[][] matrix;
        int order;
        if (chooseFileInput()) {
            getFileNormalReading();
            matrix = readFileMatrix();
        }
        else {
            matrix = readConsoleMatrix();
        }
        return matrix;
    }

    public static int[] findGoodMen(int[][] matrix, int[] goodMen) {
        boolean goodMarks;
        goodMarks = true;
        for (int row = 0; row < LAST_STUDENT; row++) {
            for (int col = 0; col < LAST_COLUMN; col++) {
                if (matrix[row][col] < 9)
                    goodMarks = false;
            }
            if (goodMarks)
                goodMen[row] = row + 1;
            goodMarks = true;
        }
        return goodMen;
    }

    public static boolean chooseFileOutput() {
        int isFileOutput;
        boolean isCorrect, choose;
        isFileOutput = 0;
        choose = true;
        do {
            System.out.println("Вы хотите выводить матрицу через файл? (Да - " + 1 + " / Нет - " + 0 + ")");
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

    public static void printConsoleResult(int[] goodMen) {
        int row;
        row = 0;
        System.out.print("Номера отличников:\n");
        for (row = 0; row < LAST_STUDENT; row++)
            if (goodMen[row] > 0)
                System.out.print(goodMen[row] + " ");
    }

    public static void printFileResult(int[] goodMen) {
        int row;
        row = 0;
        try {
            FileWriter writer = new FileWriter(file, true);
            writer.write("Номера отличников:\n");
            while (row < LAST_STUDENT) {
                if (goodMen[row] > 0)
                    writer.write(goodMen[row] + " ");
                row++;
            }
            writer.close();
        } catch (IOException e) {}
    }

    public static void printResult(int[] goodMen) {
        if (chooseFileOutput()) {
            getFileNormalWriting();
            printFileResult(goodMen);
        }
        else
            printConsoleResult(goodMen);
    }
    public static void main(String[] args) {
        int[][] matrix;
        int[] goodMen = new int [LAST_STUDENT];
        int arrLen;
        int[][] resMatrix;
        printTask();
        matrix = readMatrix();

        findGoodMen(matrix, goodMen);

        printResult(goodMen);
        scanConsole.close();
    }
}
