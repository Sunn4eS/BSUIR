import java.io.File;
import java.io.FileWriter;
import java.util.Objects;
import java.util.Scanner;

public class Main {
    enum ErrCode {
        CORRECT,
        FILE_NOT_EXIST,
        NOT_TXT,

        INPUT_ERR,
        NOT_READABLE,
        FILE_EMPTY,
        NOT_WRITEABLE,
        RANGE_ERR,
        EXTRA_DATA,
        SAME_TOWNS
    }
    static final String[] ERRORS = {"Удача",
            "Такого файла не существует!",
            "Файл не .txt!",

            "Проверьте корректность ввода данных!",
            "Файл закрыт для чтения!",
            "Файл пуст!",
            "Файл закрыт для записи!",
            "Данные не входят в диапазон!",
            "Лишние данные в файле!",
            "Пуь не может начинаться и заканчиваться в одном месте!"
    };
    static final String INSTRUCTION = "\nДанная програма находит путь между городами\n" +
            "1. Максимальное количество городов 30.\n" +
            "2. Чтобы добавлять контанты из файла нужно записывать количество городов на первой строке.\n " +
            "   Матрицу смежности для графа с городами на второй.\n" +
            "   Начальный и конечный город через пробел на последней строке.\n" +
            "3. При добавлении нового города старые дороги пропадают";
    enum ChooseAction {
        addTown("Добавить город"),
        addRoad("Добавить дорогу"),
        addCityFromFile("Добавить города и дороги из файла"),
        findPathBetweenTowns("Найти путь от А до Б"),
        clearGraph("Очистить города"),
        saveResult("Сохранить путь в файл"),
        exitProg("Заверишть программу");

        private final String info;

        ChooseAction (String inf) {
            this.info = inf;
        }
        private String getInf() {
            return this.ordinal() + ") " + this.info;
        }
    }

    static class StackList {
        int value;
        StackList next;
    }
    static StackList top = null;
    public static void iStack() {
        top = null;
    }
    public static void pushStack(int value) {
        StackList newItem = new StackList();
        newItem.value = value;
        newItem.next = top;
        top = newItem;
    }
    public static void popStack() {
        StackList removeItem = top;
        top = removeItem.next;
    }
    public static String stackToStr() {
        String pathStr = " ";
        StackList item = top;
        if (item == null)  {
            pathStr = "Путь не найден!";
        } else {
            while (item != null) {
                pathStr = pathStr + " ," + item.value;
                item = item.next;
            }
            StringBuilder reversed = new StringBuilder(pathStr).reverse();
            pathStr =  "Ваш путь: " + reversed;
        }
        return pathStr;
    }

    static class GrLinkedList {
        int number;
        GrLinkedList next;
    }
    static GrLinkedList head = null;
    static int countOfTowns = 1;
    static boolean[][] graphMatrix;
    static boolean[] visited;
    static String pathStr;
    public static void make() {
        head = new GrLinkedList();
        head.next = null;
        head.number = countOfTowns;
    }
    public static void addLink(int startTown, int endTown) {
        graphMatrix[startTown - 1][endTown - 1] = true;
        graphMatrix[endTown - 1][startTown - 1] = true;
    }
    public static void addTown() {
        GrLinkedList town;
        if (head == null)
            make();
        else {
            town = head;
            while (town.next != null)
                town = town.next;

            town.next = new GrLinkedList();
            town = town.next;
            countOfTowns++;
            town.number = countOfTowns;
            town.next = null;
        }
        graphMatrix = new boolean[countOfTowns][countOfTowns];
        for (int i = 0; i < graphMatrix.length - 1; i++) {
            for (int j = 0; j < graphMatrix.length - 1; j++)
                graphMatrix[i][j] = false;
        }
    }
    public static void clearGraph() {
        GrLinkedList buff;
        graphMatrix = null;
        buff = head;
        while (buff != null) {
            head = buff.next;
            buff = null;
            buff = head;
        }
        head = null;
        countOfTowns = 1;
        visited = null;
    }
    public static String findPathDfs(int startPoint, int endPoint) {
        visited = new boolean[countOfTowns];
        iStack();
        for (int i = 0; i < countOfTowns; i++)
            visited[i] = false;
        if (dfs(startPoint, endPoint)) {
            return stackToStr();
        } else {
            return stackToStr();
        }
    }
    public static boolean dfs(int startPoint, int endPoint) {
        visited[startPoint - 1] = true;
        boolean ready = false;
        int j = 0;
        int neighbor = 0;

        pushStack(startPoint);
        if (startPoint == endPoint) {
            ready = true;
        } else {
            while ((j < graphMatrix.length) && !ready) {
                if (graphMatrix[startPoint - 1][j]) {
                    neighbor = j + 1;
                    if (!visited[neighbor - 1]) {
                        if (dfs(neighbor, endPoint)) {
                            ready = true;
                        }
                    }
                }
                j++;
            }
            if (!ready) {
                popStack();
            }
        }
        return ready;
    }

    public static boolean doMenu (Scanner input) {
        boolean close = false;
        System.out.print("Введите действие: ");
        ChooseAction option = getChoice(input);
        System.out.println();

        switch (option) {
            case addTown -> {
                if (countOfTowns < 30) {
                    addTown();
                    System.out.println("Город успешно добавлен!");
                    System.out.println("Количество городов: " + countOfTowns + "\n");
                } else {
                    System.out.println("Количество городов больше 30!");
                }
            }
            case addCityFromFile -> {
                pathStr = readFileMatrix(input);
                visualiseGraph();
                System.out.println(pathStr);
            }
            case addRoad -> {
                if (countOfTowns > 1) {
                    addNewRoad(input);
                    System.out.println("Дорога успешно добавлена!");
                    visualiseGraph();
                } else {
                    System.out.println("Количество городов должно быть больше двух!");
                }
            }
            case findPathBetweenTowns -> {
                if (countOfTowns > 1) {
                    pathStr = getPath(input);
                    System.out.println(pathStr);
                } else {
                    System.out.println("Количество городов должно быть больше двух!");
                }
            }
            case clearGraph -> {
               clearGraph();
               System.out.println("Города очищены!");
            }
            case saveResult -> {
                if (!Objects.equals(pathStr, ""))
                    saveUpDownList(input, pathStr);
                else
                    System.out.println("Вы ещё не находили путь!");
            }
            case exitProg ->
                close = true;
        }
        return close;
    }
    public static void printMenu() {
        ChooseAction[] choices = ChooseAction.values();
        for (ChooseAction choice : choices) {
            System.out.println(choice.getInf());
        }
    }
    public static void addNewRoad (Scanner input) {
        int startPoint;
        int endPoint;
        do {
            System.out.print("Введите стартовый город: ");
            startPoint = getNumConsole(input, 1, countOfTowns);

            System.out.print("Введите конечный город: ");
            endPoint = getNumConsole(input, 1, countOfTowns);
            if (startPoint == endPoint) {
                System.out.println("Дорога не может начинаться и заканчиваться в одном городе!");
            }
        } while (startPoint == endPoint);
        addLink(startPoint, endPoint);
    }
    public static void visualiseGraph () {
        System.out.println("Ваши дороги: ");
        System.out.print("    ");
        for (int k = 0; k < countOfTowns; k++)
            System.out.print(k + 1 + " ");
        System.out.println();
        for (int i = 0; i < countOfTowns; i++) {
            if (i < 9) {
                System.out.print(i + 1 + "|  ");
            } else {
                System.out.print(i + 1 + "| ");
            }
            for (int j = 0; j < countOfTowns; j++) {

                if (graphMatrix[i][j]) {
                    System.out.print("1");
                } else {
                    System.out.print("0");
                }
                if (j < 9) {
                    System.out.print(" ");
                } else {
                    System.out.print("  ");
                }
            }
            System.out.println();
        }
    }
    public static String getPath (Scanner input) {
        String pathStr;
        int startPoint;
        int endPoint;
        do {
            System.out.print("Введите стартовый город: ");
            startPoint = getNumConsole(input, 1, countOfTowns);

            System.out.print("Введите конечный город: ");
            endPoint = getNumConsole(input, 1, countOfTowns);
            if (startPoint == endPoint) {
                System.out.println("Дорога не может начинаться и заканчиваться в одном городе!");
            }
        } while (startPoint == endPoint);
        pathStr = findPathDfs(startPoint, endPoint);
        return pathStr;
    }

    public static void printError (ErrCode error) {
        System.out.println("\n" + ERRORS[error.ordinal()] + "\nПовторите попытку\n");
    }
    static ErrCode readOneNum(Scanner inputScanner, int[] numberArr, final int MIN, final int MAX, boolean isFile) {
        int number = 0;
        ErrCode error;
        error = ErrCode.CORRECT;
        try {
            if (isFile)
                number = (inputScanner.nextInt());
            else
                number = Integer.parseInt(inputScanner.nextLine());
        } catch (NumberFormatException e) {
            error = ErrCode.INPUT_ERR;
        }
        if (error == ErrCode.CORRECT && ((number < MIN) || (number > MAX)))
            error = ErrCode.RANGE_ERR;
        numberArr[0] = error == ErrCode.CORRECT ? number : 0;
        return error;
    }
    public static int getNumConsole(Scanner input, final int MIN, final int MAX) {
        ErrCode err;
        int[] numberArr = {0};
        do {
            err = readOneNum(input, numberArr, MIN, MAX, false);
            if (err != ErrCode.CORRECT) {
                System.err.printf(ERRORS[err.ordinal()], MIN, MAX);
                System.out.println("\nВведите снова");
            }
        } while (err != ErrCode.CORRECT);
        return numberArr[0];
    }
    static ChooseAction getChoice(Scanner input) {
        int choice;
        int maxChoice = ChooseAction.values().length - 1;
        choice = getNumConsole(input, 0, maxChoice);
        return ChooseAction.values()[choice];
    }
    public static String readPath (Scanner inputScanner) {
        String pathTofile;
        ErrCode error;

        do {
            System.out.print("Введите путь к txt файлу: ");
            pathTofile = inputScanner.nextLine();
            if (pathTofile.isEmpty()) {
                pathTofile = inputScanner.nextLine();
            }
            if (!pathTofile.endsWith(".txt")) {
                error = ErrCode.NOT_TXT;
            } else {
                error = ErrCode.CORRECT;
            }
            if (error != ErrCode.CORRECT)
                printError(error);
        } while (error != ErrCode.CORRECT);
        return pathTofile;
    }
    public static File fileReading (Scanner inputScanner) {
        ErrCode error;
        String pathToFile;
        File file;
        do {
            error = ErrCode.CORRECT;
            pathToFile = readPath(inputScanner);
            file = new File(pathToFile);
            if (!file.exists())
                error = ErrCode.FILE_NOT_EXIST;
            if ((error == ErrCode.CORRECT) && (!file.canRead()))
                error = ErrCode.NOT_READABLE;
            if ((error == ErrCode.CORRECT) && (file.length() == 0))
                error = ErrCode.FILE_EMPTY;
            if (error != ErrCode.CORRECT)
                printError(error);
        } while (error != ErrCode.CORRECT);
        return file;
    }
    public static File fileWriting(Scanner inputScanner) {
        ErrCode error;
        File file;
        String pathToFile;
        do {
            pathToFile = readPath(inputScanner);
            file = new File(pathToFile);
            error = ErrCode.CORRECT;

            if (!file.exists())
                error = ErrCode.FILE_NOT_EXIST;
            if ((error == ErrCode.CORRECT) && !file.canWrite())
                error = ErrCode.NOT_WRITEABLE;
            if (error != ErrCode.CORRECT)
                printError(error);
        } while (error != ErrCode.CORRECT);
        return file;
    }
    static ErrCode checkSpaceInFile(String bufStr) {
        int i;
        ErrCode error;
        i = 0;
        error = ErrCode.CORRECT;
        while ((error == ErrCode.CORRECT) && (i < bufStr.length())) {
            if (bufStr.charAt(i) != ' ')
                error = ErrCode.EXTRA_DATA;
            i++;
        }
        return error;
    }
    public static boolean[][] readMatrix(Scanner inputScanner, int[] numberArr, int m, int n, int option) {
        int i;
        int j;
        boolean[][] matrix;
        String bufStr;
        ErrCode error;
        error = ErrCode.CORRECT;
        i = 0;
        matrix = new boolean[n][m];
        while (i < n && error == ErrCode.CORRECT) {
            j = 0;
            while (j < m && error == ErrCode.CORRECT) {
                if (option == 1) {
                    error = readOneNum(inputScanner, numberArr, 0, 1, true);
                    if (error == ErrCode.CORRECT) {
                        matrix[i][j] = numberArr[0] != 0;
                    }
                    j++;
                }
            }
            if (option == 1 && error == ErrCode.CORRECT) {
                bufStr = inputScanner.nextLine();
                error = checkSpaceInFile(bufStr);
            }
            i++;
        }
        if (error != ErrCode.CORRECT) {
            matrix = null;
            printError(error);
        }
        return matrix;
    }
    public static String readFileMatrix(Scanner inputScanner) {
        int[] numberArr = new int[1];
        int[] numberCountOfTowns = new int[1];
        int[] numberStart = new int[1];
        int[] numberEnd = new int[1];

        ErrCode error;
        File file;
        do {
            file = fileReading(inputScanner);
            try(Scanner scanFile = new Scanner(file)) {
                error = readOneNum(scanFile, numberCountOfTowns, 1, 30, true);
                if (error == ErrCode.CORRECT) {

                    countOfTowns = numberCountOfTowns[0];
                    graphMatrix = readMatrix(scanFile, numberArr, countOfTowns, countOfTowns, 1);
                    error = readOneNum(scanFile, numberStart, 1, countOfTowns, true);
                    if (error == ErrCode.CORRECT) {
                        error = readOneNum(scanFile, numberEnd, 1, countOfTowns, true);
                    }
                    if (numberStart[0] == numberEnd[0]) {
                        error = ErrCode.SAME_TOWNS;
                    }
                }
            } catch (Exception e) {
                error = ErrCode.NOT_READABLE;
                printError(error);
            }
            if (graphMatrix == null)
                error = ErrCode.INPUT_ERR;

            if (error != ErrCode.CORRECT) {
                printError(error);
            }
        } while (error != ErrCode.CORRECT);

        return findPathDfs(numberStart[0], numberEnd[0]);
    }

    public static void saveUpDownList (Scanner inputScanner, String pathStr) {
        File file = fileWriting(inputScanner);
        try (FileWriter writer = new FileWriter(file, true)) {
            writer.write(pathStr);
            System.out.println("Путь сохранен успешно.\n");
        } catch (Exception e) {
            printError(ErrCode.NOT_WRITEABLE);
        }
    }

    public static void main(String[] args) {
        boolean isExit;
        Scanner input = new Scanner(System.in);
        System.out.println(INSTRUCTION);
        do {
            printMenu();
            isExit = doMenu(input);
        } while (!isExit);
        input.close();
    }
}

