import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
public class Main {
    public static final int  MIN_MATRIX = 2;
    public static final int  MAX_MATRIX = 100;
    public static final int  MIN_ELEMENT = -1000;
    public static final int  MAX_ELEMENT = 1000;
    public enum ERRORS_LIST {
        CORRECT, RANGE_ERR, NUM_ERR, NOT_TXT, NOT_EXIST, NOT_READABLE, NOT_WRITEABLE, ORDER_ERR, CHOICE_ERR, FILE_EMPTY
    }
    public static final String[]
            ERRORS = {
            "", "Значение не попадает в диапазон!", "Проверьте корректность ввода данных!", "Расширение не txt!", "Проверьте корректность ввода пути к файлу!", "Файл закрыт для чтения!", "Файл закрыт для записи!", "Значения порядков не равны!", "Проверьте корректность выбора!", "Файл пуст!" };
    public static Scanner scanConsole = new Scanner(System.in);
    public static Scanner scanFile;
    public static File file;
    public static void printTask() {
        System.out.println("Данная программа располагает строки матрицы по возрастанию эелементов побочной диагонали исходной матрицы:\n\n");
    }
    public static void printError (ERRORS_LIST error) {
        System.out.println(ERRORS[error.ordinal()] + "\nПовторите попытку");
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
        int num = 0;
        do {
            error = ERRORS_LIST.CORRECT;
            try {
                num = Integer.parseInt(scanConsole.nextLine());
            } catch (NumberFormatException e) {
                error = ERRORS_LIST.CHOICE_ERR;
            }
        } while (error != ERRORS_LIST.CORRECT);
        return num;
    }
    public static int[][] copyMatrix(int[][] matrix, int order) {
        int [][] resMatrix = new int[order][order];
        for (int i = 0; i < order; ++i) {
            resMatrix[i] = new int[order];
            for (int j = 0; j < order; ++j)
                resMatrix[i][j] = matrix[i][j];
        }
        return resMatrix;
    }
    public static boolean checkInOut() {
        final int FILE_CHOICE = 1;
        final int CONSOLE_CHOICE = 2;
        int num = 0;
        boolean choose = false;
        num = checkNum(FILE_CHOICE, CONSOLE_CHOICE);
        if (num == 1)
            choose = true;
        return choose;
    }
    public static boolean chooseFileInput() {
        boolean choose = true;
        System.out.println("Вы хотите вводить матрицу через файл? (Да - " + 1 + " / Нет - " + 2 + ")");
        choose = checkInOut();
        return choose;
    }
    public static String ReadPath(){
        ERRORS_LIST error;
        String pathToFile = " ";
        do {
            error = ERRORS_LIST.CORRECT;
            System.out.print("Введите путь к файлу с расширением .txt: ");
            pathToFile = scanConsole.nextLine();
            if (!pathToFile.endsWith(".txt"))
                error = ERRORS_LIST.NOT_TXT;
        } while (error != ERRORS_LIST.CORRECT);
        return pathToFile;
    }
    public static void fileReading () {
        ERRORS_LIST error;
        String pathToFile = "";
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
        String pathToFile = "";
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
    public static int readOrderFile(){
        int order = 0;
        ERRORS_LIST error;
        error = ERRORS_LIST.CORRECT;
        int rows, cols, buf;
        rows = 0;
        buf = 0;
        cols = 0;
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        order = scanFile.nextInt();
        error = checkArea(order, MIN_MATRIX, MAX_MATRIX);
        scanFile.nextLine();
        while (error == ERRORS_LIST.CORRECT && scanFile.hasNextLine()) {
            cols = 0;
            String line = scanFile.nextLine();
            Scanner lineScanner = new Scanner(line);
            while (error == ERRORS_LIST.CORRECT && lineScanner.hasNextInt()) {
                buf = lineScanner.nextInt();
                cols++;
            }
            lineScanner.close();
            if (error == ERRORS_LIST.CORRECT) {
                rows++;
                if (cols == order)
                    error = ERRORS_LIST.CORRECT;
            }
        }
        scanFile.close();
        if (error == ERRORS_LIST.CORRECT) {
            error = checkArea(rows, MIN_MATRIX, MAX_MATRIX);
            error = checkArea(cols, MIN_MATRIX, MAX_MATRIX);
        }
        if (error == ERRORS_LIST.CORRECT && (rows != order || cols != order))
            error = ERRORS_LIST.ORDER_ERR;
        if (error != ERRORS_LIST.CORRECT)
            printError(error);
        return order;
    }
    public static int readOrderConsole() {
        int order = 0;
        System.out.print("Введите порядок матрицы [" + MIN_MATRIX + ": " + MAX_MATRIX + "]: ");
        order = checkNum(MIN_MATRIX, MAX_MATRIX);
        return order;
    }
    public static int[][] readMatrixConsole(int order) {
        int[][] matrix = new int[order][order];
        Scanner scanConsole = new Scanner(System.in);
        ERRORS_LIST error;
        error = ERRORS_LIST.CORRECT;
        for (int row = 0; row < order; row++) {
            for (int col = 0; col < order; col++) {
                do {
                    System.out.print("Введите в " + (row + 1) + " строке " + (col + 1) + " столбце элемент[" + MIN_ELEMENT + ":" + MAX_ELEMENT + "]: ");
                    error = ERRORS_LIST.CORRECT;
                    try  {
                        matrix[row][col] = Integer.parseInt(scanConsole.nextLine());
                    } catch (NumberFormatException e) {
                        error = ERRORS_LIST.NUM_ERR;
                    }
                    if (error == ERRORS_LIST.CORRECT)
                        error = checkArea(matrix[row][col], MIN_ELEMENT, MAX_ELEMENT);
                } while (!(error == ERRORS_LIST.CORRECT));
            }
        }
        return matrix;
    }
    public static int[][] readMatrixFile(int order) {
        int[][] matrix;
        matrix = new int[order][order];
        ERRORS_LIST error = ERRORS_LIST.CORRECT;
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        scanFile.nextLine();
        for (int row = 0; row < order; row++)
            for (int col = 0; col < order; col++) {
                try {
                    matrix[row][col] = scanFile.nextInt();
                } catch (NumberFormatException e){
                    error = checkArea(MIN_ELEMENT, MAX_ELEMENT, matrix[row][col]);
                }

            }
        scanFile.close();
        if (error != ERRORS_LIST.CORRECT)
            printError(error);
        return matrix;
    }
    public static int[][] readMatrix() {
        int[][] matrix;
        int order;
        boolean isFromConsole = (!chooseFileInput());
        if (!isFromConsole) {
            fileReading();
            order = readOrderFile();
            matrix = readMatrixFile(order);
        }
        else {
            order = readOrderConsole();
            matrix = readMatrixConsole(order);
        }
        return matrix;
    }
    public static void swapMatrixColumns(int[][] diagonal, int col1, int col2) {
        int temp;
        for (int i = 0; i < 2; i++) {
            temp = diagonal[i][col1];
            diagonal[i][col1] = diagonal[i][col2];
            diagonal[i][col2] = temp;
        }
    }
    public static int[][] createMatrixOfDiagonalElements(int[][] matrix) {
        int[][] diagonal = new int[2][matrix.length];
        for (int i = 0; i < matrix.length; i++) {
            diagonal[0][i] = matrix[i][matrix.length - 1 - i];
            diagonal[1][i] = i;
        }
        return diagonal;
    }
    public static int[][] sortDiagonal(int[][] diagonal) {
        int minInColumn;
        int numOfColumn;
        int i;
        for (int j = 0; j < diagonal[0].length - 1; j++) {
            i = j + 1;
            minInColumn = diagonal[0][j];
            numOfColumn = j;
            while (i < diagonal[0].length) {
                if (minInColumn > diagonal[0][i]) {
                    minInColumn = diagonal[0][i];
                    numOfColumn = i;
                }
                i++;
            }
            if (numOfColumn != j)
                swapMatrixColumns(diagonal, j, numOfColumn);
        }
        return diagonal;
    }
    public static int[][] sortMatrix(int[][] matrix, int[][] diagonal) {
        int[][] resMatrix = null;
        int newLine;
        resMatrix = copyMatrix(matrix, matrix.length) ;
        for (int i = 0; i < matrix.length; i++) {
            newLine = diagonal[1][i];
            moveLines(resMatrix, matrix, newLine, i);
        }
        return resMatrix;
    }
    public static void moveLines(int[][] resMatrix, int[][] matrix, int newLine, int prevLine) {
        for (int col = 0; col < matrix.length; ++col)
            resMatrix[prevLine][col] = matrix[newLine][col];
    }
    public static boolean chooseFileOutput() {
        System.out.println("Вы хотите выводить матрицу через файл? (Да - " + 1 + " / Нет - " + 2 + ")");
        return checkInOut();
    }
    public static void printResult(int[][] resMatrix) {
        int line = 0;
        int column = 0;
        String pathToFile = "";
        boolean printToFile = chooseFileOutput();
        if (printToFile) {
            pathToFile = fileWriting();
            try (FileWriter fileOut = new FileWriter(pathToFile)) {
                fileOut.write("Отсортированная Матрица:\n");
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else
            System.out.println("Отсортированная Матрица:");
        for (line = 0; line < resMatrix.length; line++) {
            for (column = 0; column < resMatrix.length; column++) {
                if (printToFile) {
                    try (FileWriter fileOut = new FileWriter(pathToFile, true)){
                        fileOut.write(resMatrix[line][column]+" ");
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                } else
                    System.out.print(resMatrix[line][column] + " ");
            }
            if (printToFile)
                try (FileWriter fileOut = new FileWriter(pathToFile, true)) {
                    fileOut.write("\n");
                } catch (IOException e) {}
            else
                System.out.println();
        }
    }
    public static void main(String[] args) {
        int[][] matrix = null;
        int[][] diagonal = null;
        int[][] resMatrix = null;
        printTask();
        matrix = readMatrix();
        diagonal = createMatrixOfDiagonalElements(matrix);
        diagonal = sortDiagonal(diagonal);
        resMatrix = sortMatrix(matrix, diagonal);
        printResult(resMatrix);
        scanConsole.close();
    }
}
