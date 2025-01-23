import java.util.Scanner;
import java.io.File;
import java.io.FileWriter;

public class Main {

    public static final int MIN_O = 1;
    public static final int MAX_O = 9;
    public static final int MIN_MAT = 0;
    public static final int MAX_MAT = 1;

    public static class Vertex {
        String value;
        Vertex next;

        public Vertex(String value) {
            this.value = value;
            this.next = null;
        }
    }

    private static Vertex[] adjacencyArray;

    public enum ErrorsCode {
        CORRECT,
        INCORRECT_CHOICE,
        INCORRECT_NUMBER,
        FILE_NOT_TXT,
        FILE_NOT_EXIST,
        FILE_NOT_READABLE,
        FILE_IS_EMPTY,
        FILE_NOT_WRITABLE,
        INCORRECT_RANGE,
        NOT_A_NUM,
        EXTRA_DATA
    }

    public static final String[] ERRORS = {
            "Правильно",
            "Некорректный выбор!",
            "Ошибка!Введите 1 или 2",
            "Расширение файла не.txt!",
            "Проверьте корректность ввода пути к файлу!",
            "Файл закрыт для чтения!",
            "Файл пуст!",
            "Файл закрыт для записи!",
            "Число не попадает в диапазон!",
            "Проверьте корректность ввода данных!",
            "Лишние данные в файле!"};

    public static void printTask() {
        System.out.println("Данная программа преобразует матрицу смежности в списки инцидентности.");
    }

    public static int chooseOption(Scanner inputScanner) {
        ErrorsCode error;
        int option;
        String optionStr;
        option = 0;
        optionStr = "";
        do {
            error = ErrorsCode.CORRECT;
            try {
                optionStr = inputScanner.nextLine();
                option = Integer.parseInt(optionStr);
            } catch (NumberFormatException e) {
                error = ErrorsCode.INCORRECT_CHOICE;
            }
            if ((error == ErrorsCode.CORRECT) && (option != 1) && (option != 2))
                error = ErrorsCode.INCORRECT_NUMBER;
            if (error != ErrorsCode.CORRECT && (optionStr != ""))
                System.out.println(ERRORS[error.ordinal()]);
        } while (error != ErrorsCode.CORRECT);
        return option;
    }

    public static String readPathFile(Scanner inputScanner) {
        ErrorsCode error;
        String pathToFile;
        do {
            System.out.print("Введите путь к файлу: ");
            pathToFile = inputScanner.nextLine();
            if (pathToFile.endsWith(".txt"))
                error = ErrorsCode.CORRECT;
            else
                error = ErrorsCode.FILE_NOT_TXT;
            if (error != ErrorsCode.CORRECT)
                System.out.println(ERRORS[error.ordinal()]);
        } while (error != ErrorsCode.CORRECT);
        return pathToFile;
    }

    public static File getReadableFile(Scanner inputScanner) {
        File file;
        ErrorsCode error;
        String pathToFile;
        do {
            error = ErrorsCode.CORRECT;
            pathToFile = readPathFile(inputScanner);
            file = new File(pathToFile);
            if (!file.exists())
                error = ErrorsCode.FILE_NOT_EXIST;
            if (error == ErrorsCode.CORRECT && !file.canRead())
                error = ErrorsCode.FILE_NOT_READABLE;
            if (error == ErrorsCode.CORRECT && (file.length() == 0))
                error = ErrorsCode.FILE_IS_EMPTY;
            if (error != ErrorsCode.CORRECT)
                System.out.println(ERRORS[error.ordinal()]);
        } while (error != ErrorsCode.CORRECT);
        return file;
    }

    public static File getWritableFile(Scanner inputScanner) {
        File file;
        ErrorsCode error;
        String pathToFile;
        do {
            error = ErrorsCode.CORRECT;
            pathToFile = readPathFile(inputScanner);
            file = new File(pathToFile);
            if (!file.exists())
                error = ErrorsCode.FILE_NOT_EXIST;
            if (error == ErrorsCode.CORRECT && !file.canWrite())
                error = ErrorsCode.FILE_NOT_WRITABLE;
            if (error != ErrorsCode.CORRECT)
                System.out.println(ERRORS[error.ordinal()]);
        } while (error != ErrorsCode.CORRECT);
        return file;
    }

    public static ErrorsCode checkSpaceInFile(String bufStr) {
        int i;
        ErrorsCode error;
        i = 0;
        error = ErrorsCode.CORRECT;
        while ((error == ErrorsCode.CORRECT) && (i < bufStr.length())) {
            if (bufStr.charAt(i) != ' ')
                error = ErrorsCode.EXTRA_DATA;
            i++;
        }
        return error;
    }

    public static ErrorsCode readOneNum(Scanner inputScanner, int[] numberArr, final int MIN, final int MAX, boolean isFile) {
        int number = 0;
        ErrorsCode error;
        error = ErrorsCode.CORRECT;
        try {
            if (isFile)
                number = Integer.parseInt(inputScanner.next());
            else
                number = Integer.parseInt(inputScanner.nextLine());
        } catch (NumberFormatException e) {
            error = ErrorsCode.NOT_A_NUM;
        }
        if (error == ErrorsCode.CORRECT && ((number < MIN) || (number > MAX)))
            error = ErrorsCode.INCORRECT_RANGE;
        numberArr[0] = error == ErrorsCode.CORRECT ? number : 0;
        return error;
    }

    public static int[][] readMatrix(Scanner inputScanner, int[] numberArr, int order, int option) {
        int i;
        int j;
        int[][] matrix;
        String bufStr;
        ErrorsCode error;
        error = ErrorsCode.CORRECT;
        i = 0;
        matrix = new int[order][order];
        while (i < order && error == ErrorsCode.CORRECT) {
            j = 0;
            while (j < order && error == ErrorsCode.CORRECT) {
                if (option == 1) {
                    error = readOneNum(inputScanner, numberArr, MIN_MAT, MAX_MAT, true);
                    if (error == ErrorsCode.CORRECT)
                        matrix[i][j] = numberArr[0];
                } else {
                    do {
                        System.out.print("Введите в " + (i + 1) + " строке " + (j + 1) + " столбце элемент матрицы [" + MIN_MAT + "; " + MAX_MAT + "]: ");
                        error = readOneNum(inputScanner, numberArr, MIN_MAT, MAX_MAT, true);
                        if (error != ErrorsCode.CORRECT)
                            System.out.println(ERRORS[error.ordinal()]);
                        else
                            matrix[i][j] = numberArr[0];
                    } while (error != ErrorsCode.CORRECT);
                }
                j++;
            }
            if (option == 1 && error == ErrorsCode.CORRECT) {
                bufStr = inputScanner.nextLine();
                error = checkSpaceInFile(bufStr);
            }
            i++;
        }
        if (error != ErrorsCode.CORRECT) {
            matrix = null;
            System.out.println(ERRORS[error.ordinal()]);
        }
        return matrix;
    }

    public static int[][] readConsoleMatrix(Scanner inputScanner) {
        int[] numberArr = new int[1];
        int order;
        int[][] matrix = {};
        ErrorsCode error;
        do {
            System.out.print("Введите порядок матрицы n [" + MIN_O + "; " + MAX_O + "]: ");
            error = readOneNum(inputScanner, numberArr, MIN_O, MAX_O, true);
            if (error != ErrorsCode.CORRECT)
                System.out.println(ERRORS[error.ordinal()]);
            else {
                order = numberArr[0];
                matrix = readMatrix(inputScanner, numberArr, order, 2);
            }
        } while (error != ErrorsCode.CORRECT);
        return matrix;
    }

    public static int[][] readFileMatrix(Scanner inputScanner) {
        String bufStr;
        int[] numberArr = new int[1];
        int order;
        int[][] matrix = {};
        ErrorsCode error;
        File file;
        do {
            file = getReadableFile(inputScanner);
            try(Scanner scanFile = new Scanner(file)) {
                error = readOneNum(scanFile, numberArr, MIN_O, MAX_O, true);
                if (error == ErrorsCode.CORRECT) {
                    bufStr = scanFile.nextLine();
                    error = checkSpaceInFile(bufStr);
                }
                if (error != ErrorsCode.CORRECT)
                    System.out.println(ERRORS[error.ordinal()]);
                else {
                    order = numberArr[0];
                    matrix = readMatrix(scanFile, numberArr, order, 1);
                }
            } catch (Exception e) {
                error = ErrorsCode.FILE_NOT_READABLE;
                System.out.println(ERRORS[error.ordinal()]);
            }
            if (matrix == null)
                error = ErrorsCode.INCORRECT_NUMBER;
        } while (error != ErrorsCode.CORRECT);
        return matrix;
    }

    public static int[][] inputMatrix(Scanner inputScanner) {
        int[][] matrix;
        int option;
        System.out.println("\nВыберете способ ввода данных:");
        System.out.println("Через файл - 1");
        System.out.println("Через консоль - 2");
        option = chooseOption(inputScanner);
        if (option == 1) {
            matrix = readFileMatrix(inputScanner);
        } else {
            matrix = readConsoleMatrix(inputScanner);
        }
        return matrix;
    }

    public static void createAdjacencyLists(int[][] matrix) {
        Vertex temp;
        int n = matrix.length;
        adjacencyArray = new Vertex[n];

        for (int i = 0; i < n; i++) {
            adjacencyArray[i] = new Vertex("");
            adjacencyArray[i].next = null;
            temp = adjacencyArray[i];

            for (int j = 0; j < n; j++) {
                for (int k = 0; k < matrix[i][j]; k++) {
                    temp.next = new Vertex("");
                    temp = temp.next;
                    temp.value = Integer.toString(j + 1);
                    temp.next = null;
                }
            }
        }
    }

    public static void printResult(Scanner inputScanner, int n) {
        ErrorsCode error;
        File file;
        StringBuilder resultString = new StringBuilder();
        Vertex temp;
        System.out.println("\nВыберете способ вывода результата:");
        System.out.println("Через файл - 1");
        System.out.println("Через консоль - 2");
        int option = chooseOption(inputScanner);
        if (option == 1)
        {
            file = getWritableFile(inputScanner);
            try(FileWriter writer = new FileWriter(file, true)) {
                writer.write("Списки инцидентности:\n");
                for (int i = 0; i < n; i++) {
                    resultString.setLength(0);
                    writer.write(((char)(65 + i)) + ": ");
                    temp = adjacencyArray[i];
                    while (temp.next != null) {
                        if (resultString.length() != 0) {
                            resultString.append(", ");
                        }
                        resultString.append(temp.next.value);
                        temp = temp.next;
                    }
                    writer.write(resultString + "\n");
                }
            } catch (Exception e) {
                error = ErrorsCode.FILE_NOT_WRITABLE;
                System.out.println(ERRORS[error.ordinal()]);
            }
        }
        else {
            System.out.println("Списки инцидентности:");
            for (int i = 0; i < n; i++) {
                resultString.setLength(0);
                System.out.print((i + 1) + ": ");
                temp = adjacencyArray[i];
                while (temp.next != null) {
                    if (resultString.length() != 0) {
                        resultString.append(", ");
                    }
                    resultString.append(temp.next.value);
                    temp = temp.next;
                }
                System.out.println(resultString);
            }
        }
    }

    public static void main(String[] args) {
        Scanner inputScanner = new Scanner(System.in);
        int[][] matrix;
        printTask();
        matrix = inputMatrix(inputScanner);
        createAdjacencyLists(matrix);
        printResult(inputScanner, matrix.length);
        inputScanner.close();
    }
}
