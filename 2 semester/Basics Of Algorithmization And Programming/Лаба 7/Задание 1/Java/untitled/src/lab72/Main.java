package lab72;

import java.util.Scanner;

public class Main {

    static VertexList VList;

    enum ErrCode {
        SUCCESS,
        INCORRECT_DATA,
        SUCH_ELEMENT_ALREADY_EXIST,
        EDGE_NOT_CORRECT,
        VERTEX_NOT_CORRECT,
        GRAPH_NOT_EXIST,
    }
    enum Choice {
        createGraph("Создать новый граф"),
        addVertex("Добавить вершину"),
        addEdge("Добавить ребро"),
        print("Вывести граф"),
        matrix("Матрица смежности"),
        deleteVertex("Удалить вершину"),
        deleteEdge("Удалить ребро"),
        findWays("Найти кратчайшие"),
        close("Закрыть");

        private final String inf;
        Choice (String infLine) {
            this.inf = infLine;
        }
        private String getInf(){return this.ordinal() + ") " + this.inf;}
    }
    static final String[] ERRORS = {"Удача",
                                    "Данные некорректные или число слишком большое (должно быть от %d до %d)\n",
                                    "Такая вершина уже существует",
                                    "Некорректное ребро",
                                    "Некорректная вершина",
                                    "Сначала стоит создать граф)",};
    static final String INFORMATION_TEXT = """
                        Инструкция:
                            -- Вершины графа должны быть от 1 до 99
                            -- Вершины графа не могут повторяться
                        """,
                        ATTENTION_TEXT = """
                        Внимание! Если граф уже существует он удалиться, вы уверены?
                            1) Да
                            2) Нет
                        """;
    static final int MIN_VERT = 1,
                     MAX_VERT = 99;
    static ErrCode enterOneNum(int[] numberArr, Scanner input, final int MIN, final int MAX) {
        int number = 0;
        ErrCode err = ErrCode.SUCCESS;
        try {
            number = Integer.parseInt(input.nextLine());
        } catch (NumberFormatException e) {
            err = ErrCode.INCORRECT_DATA;
        }
        if ((err == ErrCode.SUCCESS) && (number < MIN || number > MAX))
            err = ErrCode.INCORRECT_DATA;
        numberArr[0] = err == ErrCode.SUCCESS ? number : 0;
        return err;
    }

    static int getNumConsole(Scanner input, final int MIN, final int MAX) {
        ErrCode err;
        int[] numberArr = {0};
        do {
            err = enterOneNum(numberArr, input, MIN, MAX);
            if (err != ErrCode.SUCCESS) {
                System.err.printf(ERRORS[err.ordinal()], MIN, MAX);
                System.out.println("Введите снова");
            }
        } while (err != ErrCode.SUCCESS);
        return numberArr[0];
    }
    static void printMenu() {
        Choice[] choices = Choice.values();
        for (Choice choice : choices) {
            System.out.println(choice.getInf());
        }
    }
    static void printInf(Scanner input) {
        System.out.println(INFORMATION_TEXT);
        System.out.println("нажмите enter чтобы продолжить");
        input.nextLine();
    }

    static Choice getChoice(Scanner input) {
        printMenu();
        int choice;
        int maxChoice = Choice.values().length - 1;
        choice = getNumConsole(input, 0, maxChoice);
        return Choice.values()[choice];
    }


    static void doFunction(Choice choice, Scanner input) {
        switch (choice) {
            case createGraph -> {
                System.out.println(ATTENTION_TEXT);
                int localChoice = getNumConsole(input, 1, 2);
                if (localChoice == 1)
                    VList = new VertexList();
            }
            case addVertex -> {
                if (VList != null) {
                    System.out.println("Введите новую вершину: ");
                    int newVert = getNumConsole(input, MIN_VERT, MAX_VERT);
                    if (!VList.addVertex(newVert)) {
                        System.err.println(ERRORS[ErrCode.SUCH_ELEMENT_ALREADY_EXIST.ordinal()]);
                    }
                }
                else
                    System.err.println(ERRORS[ErrCode.GRAPH_NOT_EXIST.ordinal()]);
            }
            case addEdge -> {
                if (VList != null) {
                    System.out.println("Введите первую вершину: ");
                    int startVert = getNumConsole(input, MIN_VERT, MAX_VERT);
                    System.out.println("Введите вторую вершину: ");
                    int endVert = getNumConsole(input, MIN_VERT, MAX_VERT);
                    if (!VList.addEdge(startVert, endVert)) {
                        System.err.println(ERRORS[ErrCode.EDGE_NOT_CORRECT.ordinal()]);
                    }
                }
                else
                    System.err.println(ERRORS[ErrCode.GRAPH_NOT_EXIST.ordinal()]);
            }
            case print -> {
                if (VList != null)
                    VList.print();
                else
                    System.err.println(ERRORS[ErrCode.GRAPH_NOT_EXIST.ordinal()]);
                System.out.println();
            }
            case matrix -> {
                if (VList != null)
                    VList.printMatrix();
                else
                    System.err.println(ERRORS[ErrCode.GRAPH_NOT_EXIST.ordinal()]);
                System.out.println();
            }
            case deleteEdge -> {
                if (VList != null) {
                    System.out.println("Введите первую вершину: ");
                    int startVert = getNumConsole(input, MIN_VERT, MAX_VERT);
                    System.out.println("Введите вторую вершину: ");
                    int endVert = getNumConsole(input, MIN_VERT, MAX_VERT);
                    if (!VList.deleteEdge(startVert, endVert)) {
                        System.err.println(ERRORS[ErrCode.EDGE_NOT_CORRECT.ordinal()]);
                    }
                }
                else
                    System.err.println(ERRORS[ErrCode.GRAPH_NOT_EXIST.ordinal()]);
            }
            case deleteVertex -> {
                if (VList != null) {
                    System.out.println("Введите вершину: ");
                    int newVert = getNumConsole(input, MIN_VERT, MAX_VERT);
                    if (!VList.deleteVertex(newVert)) {
                        System.err.println(ERRORS[ErrCode.SUCH_ELEMENT_ALREADY_EXIST.ordinal()]);
                    }
                }
                else
                    System.err.println(ERRORS[ErrCode.GRAPH_NOT_EXIST.ordinal()]);
            }
            case findWays -> {
                if (VList != null) {
                    System.out.println("Введите стартовую вершину: ");
                    int vert = getNumConsole(input, MIN_VERT, MAX_VERT);
                    if (VList.containce(vert)) {
                        VList.findWay(vert);
                    } else
                        System.err.println(ERRORS[ErrCode.VERTEX_NOT_CORRECT.ordinal()]);
                }
                else
                    System.err.println(ERRORS[ErrCode.GRAPH_NOT_EXIST.ordinal()]);
            }
        }
    }
    public static void main(String[] args){
        Scanner input = new Scanner(System.in);
        printInf(input);
        Choice choice;
        do {
            choice = getChoice(input);
            if (choice != Choice.close)
                doFunction(choice, input);
        } while (choice != Choice.close);
        input.close();
    }
}
