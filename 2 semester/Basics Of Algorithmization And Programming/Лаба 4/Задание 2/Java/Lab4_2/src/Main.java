import java.util.Scanner;
import java.io.File;
import java.io.FileWriter;
public class Main {
    public static final int  MIN_MATRIX = 1;
    public static final int  MAX_MATRIX = 4;
    public static final int  MIN_ELEMENT = -100;
    public static final int  MAX_ELEMENT = 100;
    public static String path = "";
    public static int stepCounter = 0;
    public static int maxSum = 0;
    public static int[][] coordArr = new int[2][2];
    public enum ERRORS_LIST {
        CORRECT,
        RANGE_ERR,
        NUM_ERR,
        NOT_TXT,
        NOT_EXIST,
        NOT_READABLE,
        NOT_WRITEABLE,
        CHOICE_ERR,
        FILE_EMPTY,
        EXTRA_DATA

    }
    public static final String[]
            ERRORS = {
            "",
            "Значение не попадает в диапазон!",
            "Проверьте корректность ввода данных!",
            "Расширение не txt!",
            "Проверьте корректность ввода пути к файлу!",
            "Файл закрыт для чтения!",
            "Файл закрыт для записи!",
            "Значения порядков не равны!",
            "Проверьте корректность выбора!",
            "Файл пуст!",
            "Лишние данные!"
    };
    public static void printTask() {
        System.out.println("Данная программа находит в матрице путь от элемента a[i1,j1] до элемента a[i2,j2] с максимальной суммой:\n\n");
    }
    public static void printError (ERRORS_LIST error) {
        System.out.println(ERRORS[error.ordinal()] + "\nПовторите попытку");
    }

    public static int chooseOption (Scanner inputScanner) {
        ERRORS_LIST error;
        int option = 0;
        String optionStr = "";

        do {
                error = ERRORS_LIST.CORRECT;
            try {
                option = inputScanner.nextInt();
            } catch (NumberFormatException e) {
                error = ERRORS_LIST.CHOICE_ERR;
            }
            if ((error == ERRORS_LIST.CORRECT) && (option != 1) && (option != 2)) {
                error = ERRORS_LIST.NUM_ERR;
            }
            if ((error != ERRORS_LIST.CORRECT) && (optionStr != "")) {
                printError(error);
            }
        } while (error != ERRORS_LIST.CORRECT);
        return option;
    }

    public static String readPath (Scanner inputScanner) {
        String pathTofile = "";
        ERRORS_LIST error;

        do {
            System.out.print("Введите путь к txt файлу: ");
            pathTofile = inputScanner.nextLine();
            if (pathTofile.equals("")) {
                pathTofile = inputScanner.nextLine();
            }
            if (!pathTofile.endsWith(".txt")) {
                error = ERRORS_LIST.NOT_TXT;
            } else {
                error = ERRORS_LIST.CORRECT;
            }
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
        } while (error != ERRORS_LIST.CORRECT);
        return pathTofile;
    }

    public static File fileReading (Scanner inputScanner) {
        ERRORS_LIST error;
        String pathToFile = "";
        File file;
        do {
            error = ERRORS_LIST.CORRECT;
            pathToFile = readPath(inputScanner);
            file = new File(pathToFile);
            if (!file.exists())
                error = ERRORS_LIST.NOT_EXIST;
            if ((error == ERRORS_LIST.CORRECT) && (!file.canRead()))
                error = ERRORS_LIST.NOT_READABLE;
            if ((error == ERRORS_LIST.CORRECT) && (file.length() == 0))
                error = ERRORS_LIST.FILE_EMPTY;
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
        } while (error != ERRORS_LIST.CORRECT);
        return file;
    }
    public static File fileWriting(Scanner inputScanner) {
        ERRORS_LIST error;
        File file;
        String pathToFile = "";
        do {
            pathToFile = readPath(inputScanner);
            file = new File(pathToFile);
            error = ERRORS_LIST.CORRECT;

            if (!file.exists())
                error = ERRORS_LIST.NOT_EXIST;
            if ((error == ERRORS_LIST.CORRECT) && !file.canWrite())
                error = ERRORS_LIST.NOT_WRITEABLE;
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
        } while (error != ERRORS_LIST.CORRECT);
        return file;
    }

    public static ERRORS_LIST readOneNum(Scanner inputScanner, int[] numberArr, final int MIN, final int MAX, boolean isFile) {
        int number = 0;
        ERRORS_LIST error;
        error = ERRORS_LIST.CORRECT;
        try {
            if (isFile)
                number = (inputScanner.nextInt());
            else
                number = Integer.parseInt(inputScanner.nextLine());
        } catch (NumberFormatException e) {
            error = ERRORS_LIST.NUM_ERR;
        }
        if (error == ERRORS_LIST.CORRECT && ((number < MIN) || (number > MAX)))
            error = ERRORS_LIST.RANGE_ERR;
        numberArr[0] = error == ERRORS_LIST.CORRECT ? number : 0;
        return error;
    }

    public static ERRORS_LIST checkSpaceInFile(String bufStr) {
        int i;
        ERRORS_LIST error;
        i = 0;
        error = ERRORS_LIST.CORRECT;
        while ((error == ERRORS_LIST.CORRECT) && (i < bufStr.length())) {
            if (bufStr.charAt(i) != ' ')
                error = ERRORS_LIST.EXTRA_DATA;
            i++;
        }
        return error;
    }

    public static int[][] readMatrix(Scanner inputScanner, int[] numberArr, int m, int n, int option) {
        int i;
        int j;
        int[][] matrix;
        String bufStr;
        ERRORS_LIST error;
        error = ERRORS_LIST.CORRECT;
        i = 0;
        matrix = new int[n][m];
        while (i < n && error == ERRORS_LIST.CORRECT) {
            j = 0;
            while (j < m && error == ERRORS_LIST.CORRECT) {
                if (option == 1) {
                    error = readOneNum(inputScanner, numberArr, MIN_ELEMENT, MAX_ELEMENT, true);
                    if (error == ERRORS_LIST.CORRECT)
                        matrix[i][j] = numberArr[0];
                } else {
                    do {
                        System.out.print("Введите в " + (i + 1) + " строке " + (j + 1) + " столбце элемент матрицы [" + MIN_ELEMENT + "; " + MAX_ELEMENT + "]: ");
                        error = readOneNum(inputScanner, numberArr, MIN_ELEMENT, MAX_ELEMENT, true);
                        if (error != ERRORS_LIST.CORRECT)
                            System.out.println(ERRORS[error.ordinal()]);
                        else
                            matrix[i][j] = numberArr[0];
                    } while (error != ERRORS_LIST.CORRECT);
                }
                j++;
            }
            if (option == 1 && error == ERRORS_LIST.CORRECT) {
                bufStr = inputScanner.nextLine();
                error = checkSpaceInFile(bufStr);
            }
            i++;
        }
        if (error != ERRORS_LIST.CORRECT) {
            matrix = null;
            printError(error);
        }
        return matrix;
    }

    public static int[][] readConsoleMatrix(Scanner inputScanner) {
        int[] numberM = new int[1];
        int[] numberN = new int[1];
        int[] numberArr = new int[1];
        int m;
        int n;
        int[][] matrix = {};
        ERRORS_LIST error;
        do {

            System.out.print("Введите порядок матрицы m [" + MIN_MATRIX + "; " + MAX_MATRIX + "]: ");
            error = readOneNum(inputScanner, numberM, MIN_MATRIX, MAX_MATRIX, true);
            if (error == ERRORS_LIST.CORRECT) {
                System.out.print("Введите порядок матрицы n [" + MIN_MATRIX + "; " + MAX_MATRIX + "]: ");
                error = readOneNum(inputScanner, numberN, MIN_MATRIX, MAX_MATRIX, true);
            }
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
            else {
                m = numberM[0];
                n = numberN[0];
                matrix = readMatrix(inputScanner, numberArr, m, n, 2);
            }
        } while (error != ERRORS_LIST.CORRECT);
        return matrix;
    }

    public static int[][] readFileMatrix(Scanner inputScanner) {
        String bufStr;
        int[] numberArr = new int[1];
        int[] numberM = new int[1];
        int[] numberN = new int[1];

        int m;
        int n;
        int[][] matrix = {};
        ERRORS_LIST error;
        File file;
        do {
            file = fileReading(inputScanner);
            try(Scanner scanFile = new Scanner(file)) {
                error = readOneNum(scanFile, numberM, MIN_MATRIX, MAX_MATRIX, true);
                if (error == ERRORS_LIST.CORRECT) {
                    bufStr = scanFile.nextLine();
                    error = checkSpaceInFile(bufStr);
                }
                error = readOneNum(scanFile, numberN, MIN_MATRIX, MAX_MATRIX, true);
                if (error == ERRORS_LIST.CORRECT) {
                    bufStr = scanFile.nextLine();
                    error = checkSpaceInFile(bufStr);
                }
                if (error != ERRORS_LIST.CORRECT)
                    printError(error);
                else {
                    m = numberM[0];
                    n = numberN[0];
                    matrix = readMatrix(scanFile, numberArr, m, n, 1);
                    if (matrix != null) {
                        coordArr = readFileCoord(scanFile, matrix);
                    }
                }
            } catch (Exception e) {
                error = ERRORS_LIST.NOT_READABLE;
                printError(error);
            }
            if (matrix == null)
                error = ERRORS_LIST.NUM_ERR;

        } while (error != ERRORS_LIST.CORRECT);
        return matrix;
    }

    public static int inputOption(Scanner inpuScanner) {
        int option = 0;
        System.out.println("\nВыберете способ ввода данных:");
        System.out.println("Через файл - 1");
        System.out.println("Через консоль - 2");
        option = chooseOption(inpuScanner);

        return option;
    }

    public static int[][] inputMatrix(Scanner inputScanner, int option) {
        int[][] matrix;
        if (option == 1) {
            matrix = readFileMatrix(inputScanner);
        } else {
            matrix = readConsoleMatrix(inputScanner);
        }
        return matrix;
    }

    public static int[][] readConsoleCoord (Scanner inpScanner, int [][] matrix) {
        ERRORS_LIST error;
        int [][] coordArr = new int[2][2];
        int [] numberI1 = new int[1];
        int [] numberJ1 = new int[1];
        int [] numberI2 = new int[1];
        int [] numberJ2 = new int[1];

        do {
            System.out.print("Введите координату стратового элемента I1 [" + 1 + "; " + (matrix.length) + "]: ");
            error = readOneNum(inpScanner, numberI1, MIN_MATRIX, (matrix.length), true);
            if (error == ERRORS_LIST.CORRECT) {
                System.out.print("Введите координату стратового элемента J1 [" + 1 + "; " + (matrix[0].length) + "]: ");
                error = readOneNum(inpScanner, numberJ1, MIN_MATRIX, (matrix[0].length), true);
            }
            if (error == ERRORS_LIST.CORRECT) {
                System.out.print("Введите координату стратового элемента I2 [" + 1 + "; " + (matrix.length) + "]: ");
                error = readOneNum(inpScanner, numberI2, MIN_MATRIX, (matrix.length), true);
            }
            if (error == ERRORS_LIST.CORRECT) {
                System.out.print("Введите координату стратового элемента J2 [" + 1 + "; " + (matrix[0].length) + "]: ");
                error = readOneNum(inpScanner, numberJ2, MIN_MATRIX, (matrix[0].length), true);
            }
            if (error != ERRORS_LIST.CORRECT) {
                printError(error);
            } else {
                coordArr[0][0] = numberI1[0] - 1;
                coordArr[1][0] = numberJ1[0] - 1;
                coordArr[0][1] = numberI2[0] - 1;
                coordArr[1][1] = numberJ2[0] - 1;
            }
        } while (error != ERRORS_LIST.CORRECT);

        return coordArr;
    }

    public static int[][] readFileCoord (Scanner inpScanner, int[][] matrix) {
        ERRORS_LIST errors;
        int [] numberI1 = new int[1];
        int [] numberJ1 = new int[1];
        int [] numberI2 = new int[1];
        int [] numberJ2 = new int[1];
        int shift = matrix.length + 2;
        do {
                errors = readOneNum(inpScanner, numberI1, 1, matrix.length, true);
                if (errors == ERRORS_LIST.CORRECT) {
                    errors = readOneNum(inpScanner, numberJ1, 1, matrix[0].length, true);
                }
                if (errors == ERRORS_LIST.CORRECT) {
                    errors = readOneNum(inpScanner, numberI2, 1, matrix.length, true);
                }
                if (errors == ERRORS_LIST.CORRECT) {
                    errors = readOneNum(inpScanner, numberJ2, 1, matrix[0].length, true);
                }
                if (errors == ERRORS_LIST.CORRECT) {
                    coordArr[0][0] = numberI1[0] - 1;
                    coordArr[1][0] = numberJ1[0] - 1;
                    coordArr[0][1] = numberI2[0] - 1;
                    coordArr[1][1] = numberJ2[0] - 1;
                } else {
                    printError(errors);
                }
        } while (errors != ERRORS_LIST.CORRECT);
        return coordArr;
    }

    public static int[][] inputCoord (Scanner inputScanner, int option, int[][] matrix) {
        if (option == 2) {
            coordArr = readConsoleCoord(inputScanner,matrix);
        }
        return coordArr;
    }

    public static void findpath (int[][] matrix, int i1, int j1, int i2, int j2, int currentSum, String currentPath, int [][] steps) {
        if (!((i1 < 0) || (i1 > matrix.length - 1) || (j1 < 0) || (j1 > matrix[0].length - 1) || (steps[i1][j1] >= 2))) {
            stepCounter++;
            currentPath += String.format("(%d). [%d,%d]; ", stepCounter, i1 + 1, j1 + 1);
            steps[i1][j1]++;
            currentSum += matrix[i1][j1];
            if ((i1 == i2) && (j1 == j2)) {
                if (currentSum > maxSum) {
                    maxSum = currentSum;
                    path = currentPath;
                }
            } else {
                findpath(matrix, i1, j1 + 1, i2, j2, currentSum, currentPath, steps);
                findpath(matrix,i1 + 1, j1, i2, j2, currentSum, currentPath,steps);
                findpath(matrix, i1 , j1 - 1, i2, j2, currentSum, currentPath, steps);
                findpath(matrix, i1 - 1, j1, i2, j2, currentSum, currentPath, steps);
            }

            steps[i1][j1]--;
            stepCounter--;
            currentPath = currentPath.substring(0, currentPath.length() - 7);
        }
    }

    public static int[][] createZeroMatrix (int [][] matrix) {
        int [][] zeroMatrix = new int[matrix.length ][matrix[0].length ];
        for (int i = 0; i < matrix.length; i++) {
            for (int j = 0; j < matrix[0].length; j++) {
                zeroMatrix[i][j] = 0;
            }
        }
        return zeroMatrix;
    }

    public static void printResult(Scanner inputScanner, String path) {
        ERRORS_LIST error;
        File file;
        int option = 0;
        System.out.println("\nВыберете способ вывода результата:");
        System.out.println("Через файл - 1");
        System.out.println("Через консоль - 2");
        
        option = chooseOption(inputScanner);
        if (option == 1)
        {
            file = fileWriting(inputScanner);
            try(FileWriter writer = new FileWriter(file, true)) {
                writer.write("\nПуть обхода матрицы с максимальной суммой: " + path);
            } catch (Exception e) {
                error = ERRORS_LIST.NOT_WRITEABLE;
                System.out.println(ERRORS[error.ordinal()]);
            }
        } else {
            System.out.printf("\nПуть обхода матрицы с максимальной суммой: " + path);
        }
    }


    public static void main(String[] args) {
        Scanner inpScanner = new Scanner(System.in);
        int[][] steps;
        int [][] matrix;
        int sum = 0;
        int option;

        printTask();

        option = inputOption(inpScanner);
        matrix = inputMatrix(inpScanner, option);
        steps = createZeroMatrix(matrix);
        coordArr = inputCoord(inpScanner, option, matrix);
        findpath(matrix, coordArr[0][0],coordArr[1][0], coordArr[0][1], coordArr[1][1], sum, path, steps);
        printResult(inpScanner, path);
        inpScanner.close();
    }
}
