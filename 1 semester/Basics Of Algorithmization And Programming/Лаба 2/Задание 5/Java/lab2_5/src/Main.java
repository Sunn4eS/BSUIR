import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
public class Main {
    public static final int  MIN_MATRIX = 2;
    public static final int  MAX_MATRIX = 100;
    public static final int  MIN_ELEMENT = -100000;
    public static final int  MAX_ELEMENT = 100000;
    public static Scanner scanConsole = new Scanner(System.in);
    public static Scanner scanFile;
    public static File file;
    public static void printTask() {
        System.out.println("Данная программа находит седловую точку матрицы:\n\n");
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
            System.out.println("Значение не попадает в диапазон!");
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
            System.out.println("Введите путь к файлу с расширением .txt с матрицей, у которой разряд не должен превышать " + MAX_MATRIX + ", а её элементы должны лежать в пределе [" + MIN_ELEMENT + ":" + MAX_ELEMENT + "]: ");
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
        int element;
        int order;
        boolean isCorrect;
        isCorrect = true;
        element = 0;
        order = 0;
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        try {
            order = scanFile.nextInt();
        } catch (NumberFormatException e) {
            System.out.println("Некорректный тип данных внутри файла!");
            isCorrect = false;
        }
        if (isCorrect) {
            if (!scanFile.hasNextLine()) {
                isCorrect = false;
                System.out.println("Неправильный порядок матрицы!");
            }
        }
        if (isCorrect)
            isCorrect = checkArea(order, MIN_MATRIX, MAX_MATRIX);
        scanFile.nextLine();
        while (isCorrect && scanFile.hasNextInt()) {
            try {
                element = scanFile.nextInt();
            } catch (NumberFormatException e) {
                System.out.println("Некорректный тип данных внутри файла!");
                isCorrect = false;
            }
            if (isCorrect)
                isCorrect = checkArea(element, MIN_ELEMENT, MAX_ELEMENT);
        }
        scanFile.close();
        return isCorrect;
    }
    public static boolean isOrdersEqual() {
        int order, rows, cols, k;
        boolean isCorrect;
        order = 0;
        rows = 0;
        k = 0;
        cols = 0;
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        order = scanFile.nextInt();
        scanFile.nextLine();
        isCorrect = true;
        while (isCorrect && scanFile.hasNext()) {
            Scanner lineScanFile = new Scanner(scanFile.nextLine());
            cols = 0;
            while (isCorrect && lineScanFile.hasNextInt()) {
                k = lineScanFile.nextInt();
                cols++;
            }
            if (isCorrect) {
                rows++;
                if (cols != order)
                    isCorrect = false;
            }
        }
        scanFile.close();
        if (isCorrect) {
            isCorrect = checkArea(cols, MIN_MATRIX, MAX_MATRIX);
            isCorrect = checkArea(rows, MIN_MATRIX, MAX_MATRIX);
        }
        if (isCorrect && rows != order)
            isCorrect = false;
        return isCorrect;
    }

    public static void getFileNormalReading() {
        boolean isCorrect;
        String pathToFile;
        int order;
        order = 0;
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
            if (isCorrect && !isOrdersEqual()) {
                isCorrect = false;
                System.out.println("Значения порядков не равны!");
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


    public static int readFileOrder() {
        int order;
        order = 0;
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        order = scanFile.nextInt();
        scanFile.close();
        return order;
    }
    public static int[][] readFileMatrix(int order) {
        int[][] matrix;
        matrix = new int[order][order];
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        scanFile.nextLine();
        for (int row = 0; row < order; row++)
            for (int col = 0; col < order; col++)
                matrix[row][col] = scanFile.nextInt();
        scanFile.close();
        return matrix;
    }
    public static int readConsoleOrder() {
        int order;
        boolean isCorrect;
        order = 0;
        do {
            System.out.print("Введите порядок матрицы [" + MIN_MATRIX + ":" + MAX_MATRIX + "]: ");
            isCorrect = true;
            try {
                order = Integer.parseInt(scanConsole.nextLine());
            } catch (NumberFormatException e) {
                System.out.println("Проверьте корректность ввода данных!");
                isCorrect = false;
            }
            if (isCorrect)
                isCorrect = checkArea(order, MIN_MATRIX, MAX_MATRIX);
        } while (!isCorrect);
        return order;
    }
    public static int[][] readConsoleMatrix(int order) {
        int[][] matrix;
        boolean isCorrect;
        matrix = new int[order][order];
        for (int row = 0; row < order; row++)
            for (int col = 0; col < order; col++)
                do {
                    System.out.print("Введите в " + (row + 1) + " строке " + (col + 1) + " столбце элемент[" + MIN_ELEMENT + ":" + MAX_ELEMENT + "]: ");
                    isCorrect = true;
                    try {
                        matrix[row][col] = Integer.parseInt(scanConsole.nextLine());
                    } catch (NumberFormatException e) {
                        System.out.println("Проверьте корректность ввода данных!");
                        isCorrect = false;
                    }
                    if (isCorrect)
                        isCorrect = checkArea(matrix[row][col], MIN_ELEMENT, MAX_ELEMENT);
                } while (!isCorrect);
        return matrix;
    }
    public static int[][] readMatrix() {
        int[][] matrix;
        int order;
        if (chooseFileInput()) {
            getFileNormalReading();
            order = readFileOrder();
            matrix = readFileMatrix(order);
        }
        else {
            order = readConsoleOrder();
            matrix = readConsoleMatrix(order);
        }
        return matrix;
    }

    public static int[] findMinInLine(int[][] matrix, int order) {
        int[] minInLine;
        int line;
        int column;
        line = 0;
        column = 0;
        minInLine = new int [order];
        for (line = 0; line < order; line++) {
            minInLine[line] = matrix[line][0];
            for (column = 0; column < order; column++)
                if (matrix[line][column] < minInLine[line])
                    minInLine[line] = matrix[line][column];
        }
        return minInLine;
    }

    public static int[] findMaxInColumn(int[][] matrix, int order) {
        int[] maxInColumn;
        int line;
        int column;
        line = 0;
        column = 0;
        maxInColumn = new int [order];
        for (column = 0; column < order; column++) {
            maxInColumn[column] = matrix[0][column];
            for (line = 0; line < order; line++)
                if (matrix[line][column] > maxInColumn[column])
                    maxInColumn[column] = matrix[line][column];
        }
        return maxInColumn;
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
    public static void printConsoleResult(int[] minInLine, int[] maxInColumn, int order) {
        int line;
        int column;
        boolean saddlePoint;
        line = 0;
        column = 0;
        saddlePoint = false;
        for (line = 0; line < order; line++)
            for (column = 0; column < order; column++)
                if (minInLine[line] == maxInColumn[column]) {
                    System.out.print("Седловая точка находится на месте:" + (line + 1) + " " + (column + 1) + "\n");
                    saddlePoint = true;
                }
        if (!saddlePoint)
            System.out.print("Нет седловой точки!");
    }
    public static void printFileResult(int[] minInLine, int[] maxInColumn, int order) {
        int line;
        int column;
        boolean saddlePoint;
        line = 0;
        column = 0;
        saddlePoint = false;
        try {
            FileWriter writer = new FileWriter(file, true);
            for (line = 0; line < order; line++)
                for (column = 0; column < order; column++)
                    if (minInLine[line] == maxInColumn[column])
                    {
                        writer.write("Седловая точка находится на месте:" + (line + 1) + " " + (column + 1) + "\n");
                        saddlePoint = true;
                    }
            if (!saddlePoint)
                writer.write("Нет седловой точки!");
            writer.close();
        } catch (IOException e) {}
    }
    public static void printResult(int[] minInLine, int[] maxInColumn, int order) {
        if (chooseFileOutput()) {
            getFileNormalWriting();
            printFileResult(minInLine, maxInColumn, order);
        }
        else
            printConsoleResult(minInLine, maxInColumn, order);
    }
    public static void main(String[] args) {
        int[][] matrix;
        int order;
        int[] minInLine;
        int[] maxInColumn;
        printTask();
        matrix = readMatrix();
        order = matrix.length;
        maxInColumn = findMaxInColumn(matrix, order);
        minInLine = findMinInLine(matrix, order);
        printResult(minInLine, maxInColumn, order);

        scanConsole.close();
    }
}
