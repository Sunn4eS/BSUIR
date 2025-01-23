import java.util.Scanner;

public class Main {
    public static int depth = 0;
    static final char ROOT_CHAR = '+',
            LEFT_CHAR = 'L',
            RIGHT_CHAR = 'R';
    public static final int MAX_DEPTH = 10;
    public static class TTree {
        int data;
        TTree left;
        TTree right;
        TTree(int data) {
            this.data = data;
            this.left = null;
            this.right = null;
        }
    }
    public static TTree binaryTree;

    public static TTree findLeaf(TTree binaryTree, int data) {
        if ((binaryTree == null) || (binaryTree.data == data)) {
            return binaryTree;
            
        } else if (data < binaryTree.data) {
            return findLeaf(binaryTree.left, data);
        } else {
            return findLeaf(binaryTree.right, data);
        }
    }
    public static int findDepth(TTree binaryTree) {
        int leftBranchDepth;
        int rightBranchDepth;
        if (binaryTree == null) {
            return 0;
        } else {
            leftBranchDepth = findDepth(binaryTree.left);
            rightBranchDepth = findDepth(binaryTree.right);
            if (leftBranchDepth > rightBranchDepth) {
                return leftBranchDepth + 1;
            } else {
                return rightBranchDepth + 1;
            }
        }
    }
    public static void addLeaf (TTree binaryTree, int data) {
        if(((binaryTree.left == null) && (binaryTree.data > data)) || ((binaryTree.right == null) && (binaryTree.data < data))) {
            if (binaryTree.data > data) {
                binaryTree.left = new TTree(data);
            } else {
                binaryTree.right = new TTree(data);
            }
        } else if (binaryTree.data > data) {
           addLeaf(binaryTree.left, data);
        } else {
           addLeaf(binaryTree.right, data);
        }
    }
    public static TTree findMinLeaf (TTree binaryTree) {
        while (binaryTree.left != null) {
            binaryTree = binaryTree.left;
        }
        return binaryTree;
    }
    public static TTree deleteLeaf(TTree binaryTree, int data) {
        if (binaryTree != null) {
            if (data < binaryTree.data) {
                binaryTree.left = deleteLeaf(binaryTree.left, data);
            } else if (data > binaryTree.data) {
                binaryTree.right = deleteLeaf(binaryTree.right, data);
            } else if (binaryTree.left != null && binaryTree.right != null) {
                binaryTree.data = findMinLeaf(binaryTree.right).data;
                binaryTree.right = deleteLeaf(binaryTree.right, binaryTree.data);
            } else {
                if (binaryTree.left != null) {
                    binaryTree = binaryTree.left;
                } else if (binaryTree.right != null) {
                    binaryTree = binaryTree.right;
                } else {
                    binaryTree = null;
                }
            }
        }
        return binaryTree;
    }
    public static void deleteFirstLeaf() {
        if (binaryTree == null) {
            printError(ErrCode.NOT_EXIST);
        } else {
            if (binaryTree.left != null && binaryTree.right != null) {
                binaryTree.data = findMinLeaf(binaryTree.right).data;
                binaryTree.right = deleteLeaf(binaryTree.right, binaryTree.data);
            } else {
                if (binaryTree.left != null) {
                    binaryTree = binaryTree.left;
                } else if (binaryTree.right != null) {
                    binaryTree = binaryTree.right;
                } else {
                    binaryTree = null;
                }
            }
            depth = findDepth(binaryTree);
        }
    }
    public static void delete(TTree binaryTree, int data) {
        if (binaryTree == null) {
            printError(ErrCode.NOT_EXIST);
        } else {
            if (findLeaf(binaryTree, data) == null) {
                printError(ErrCode.NOT_EXIST);
            } else {
                deleteLeaf(binaryTree, data);
                depth = findDepth(binaryTree);
            }
        }
    }
    public static void add(TTree binaryTree, int data) {
        if (findLeaf(binaryTree, data) == null) {
            addLeaf(binaryTree, data);
            int depth = findDepth(binaryTree);
            if (depth > MAX_DEPTH) {
                delete(binaryTree, data);
                printError(ErrCode.OVER_DEPTH);
            }
        } else {
            printError(ErrCode.ALREADY_EXIST);
        }
    }
    public static void makeTree(int data) {
        binaryTree = new TTree(data);
        binaryTree.left = null;
        binaryTree.right = null;
        binaryTree.data = data;
        depth = 1;
    }
    static void printTree(TTree binaryTree, int layer, char side) {
        if (binaryTree.right != null)
            printTree(binaryTree.right, layer + 1, RIGHT_CHAR);
        for (int i = 0; i < layer; i++)
            System.out.print("   ");
        System.out.println("(" + side + ")" + binaryTree.data);

        if (binaryTree.left != null)
            printTree(binaryTree.left, layer + 1, LEFT_CHAR);
    }
    enum ErrCode {
        CORRECT,
        ALREADY_EXIST,
        NOT_EXIST,
        OVER_DEPTH,
        INPUT_ERR,
        RANGE_ERR;
    }
    static final String[] ERRORS = {"",
            "Узел уже добавлен!",
            "Узел не существует!",
            "Слишком большая глубина!",
            "Проверьте корректность ввода!",
            "Значение не входит в диапазон!"
    };
    static final String INSTRUCTION = "\nДанная программа реализует бинарное дерево с возможностью прямого обхода.\n" + "\n1. Элементы в дереве не могут повторяться.\n" +
            "2. Элементы в диапазоне от 1 до 1000.\n";
    enum ChooseAction {
        addToTree("Добавить узел"),
        deleteFromTree("Удалить узел"),
        printTree("Визуализация дерева"),
        traversalTree("Обойти дерево в порядке \"левая ветвь, узел, правая ветвь\""),
        exitProg("Заверишть программу");

        private final String info;

        ChooseAction (String inf) {
            this.info = inf;
        }
        private String getInf(){
            return this.ordinal() + ") " + this.info;
        }
    }
    public static void  addLeafToTree (Scanner input) {
        System.out.println("Введите новый узел для дерева:");
        int data = getNumConsole(input, 0, 1000);
        if (binaryTree == null) {
            makeTree(data);
        } else {
            add(binaryTree, data);
        }
    }
    public static void deleteLeafFromTree (Scanner input) {
        System.out.println("Введите номер узла который хотите удалить:");
        int data = getNumConsole(input, 0, 1000);
        if ((binaryTree != null) && (binaryTree.data == data)) {
            deleteFirstLeaf();
        } else {
            delete(binaryTree,data);
        }
    }
    public static String traversalTree (TTree binaryTree) {
        String result = "";
        if (binaryTree != null) {
            result += traversalTree(binaryTree.left);
            result += binaryTree.data + " ";
            result += traversalTree(binaryTree.right);
        }
        return result;
    }
    public static boolean doMenu (Scanner input) {
        boolean close = false;
        System.out.print("Введите действие: ");
        ChooseAction option = getChoice(input);
        System.out.println();

        switch (option) {
            case addToTree -> {
                addLeafToTree(input);
                System.out.println("Узел добавлен.");
            }
            case deleteFromTree -> {
                deleteLeafFromTree(input);
                System.out.println("Узел удалён.");
            }
            case printTree -> {
                printTree(binaryTree, 0, ROOT_CHAR);
            }
            case traversalTree -> {
                System.out.print("Обход дерева: ");
                System.out.println(traversalTree(binaryTree));
            }
            case exitProg -> {
                close = true;
            }
        }
        return close;
    }
    static void printMenu() {
        ChooseAction[] choices = ChooseAction.values();
        for (ChooseAction choice : choices) {
            System.out.println(choice.getInf());
        }
    }
    public static void printError (ErrCode error) {
        System.out.println("\n" + ERRORS[error.ordinal()] + "\nПовторите попытку\n");
    }
    public static ErrCode readOneNum(Scanner inputScanner, int[] numberArr, final int MIN, final int MAX) {
        int number = 0;
        ErrCode error;
        error = ErrCode.CORRECT;
        try {
            number = Integer.parseInt(inputScanner.nextLine());
        } catch (NumberFormatException e) {
            error = ErrCode.INPUT_ERR;
        }
        if (error == ErrCode.CORRECT && ((number < MIN) || (number > MAX)))
            error = ErrCode.RANGE_ERR;
        numberArr[0] = error == ErrCode.CORRECT ? number : 0;
        return error;
    }
    static int getNumConsole(Scanner input, final int MIN, final int MAX) {
        ErrCode err;
        int[] numberArr = {0};
        do {
            err = readOneNum(input, numberArr, MIN, MAX);
            if (err != ErrCode.CORRECT) {
                System.out.printf(ERRORS[err.ordinal()], MIN, MAX);
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

    public static void main(String[] args) {
        boolean isExit;
        Scanner input = new Scanner(System.in);
        System.out.println(INSTRUCTION);
        do {
            printMenu();
            System.out.println();
            isExit = doMenu(input);
        } while (!isExit);
        input.close();
    }
}

