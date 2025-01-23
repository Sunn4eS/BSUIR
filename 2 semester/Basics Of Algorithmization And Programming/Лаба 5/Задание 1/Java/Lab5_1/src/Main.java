import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Scanner;

public class Main {

    enum ErrCode {
        CORRECT,
        FILE_NOT_EXIST,
        NOT_TXT,
        EMPTY_LIST,
        INPUT_ERR,
        NOT_READABLE,
        FILE_EMPTY,
        NOT_WRITEABLE,
        RANGE_ERR
    }
    static final String[] ERRORS = {"Удача",
            "Такого файла не существует!",
            "Файл не .txt!",
            "Список контактов пуст!",
            "Проверьте корректность ввода данных!",
            "Файл закрыт для чтения!",
            "Файл пуст!",
            "Файл закрыт для записи!",
            "Данные не входят в диапазон"
    };
    static final String INSTRUCTION = "\n1. Номера телефонов должны начинаться с кода.\n" +
                                      "2. Чтобы добавлять контанты из файла нужно записывать имя на первой строке и номер с кода на второй.\n";
    enum ChooseAction {
        addToList("Добавить контакт"),
        addToListFromFile("Добавить контакт(ы) из файла"),
        deleteContact("Удалить контакт"),
        printStraight("Вывести список контактов в прямом порядке"),
        printReverse("Вывести список контактов в обратном порядке"),
        saveList("Сохранить контакты в файл"),
        exitProg("Заверишть программу");

        private final String info;

        ChooseAction (String inf) {
            this.info = inf;
        }
        private String getInf(){
            return this.ordinal() + ") " + this.info;
        }
    }

    public static boolean doMenu (Scanner input) {
        boolean close = false;
        ErrCode error;
        System.out.print("Введите действие: ");
        ChooseAction option = getChoice(input);
        System.out.println();

        switch (option) {
            case addToList -> {
                createContact(input);
            }
            case addToListFromFile -> {
                addContFromFile(input);
            }
            case deleteContact -> {
                deleteContact(input);
            }
            case printStraight -> {
                if (countOfContacts != 0) {
                    printUpDownListConsole();
                } else {
                    printError(ErrCode.EMPTY_LIST);
                }
                System.out.println();
            }
            case printReverse -> {
                if (countOfContacts != 0) {
                    printDownUpListConsole();
                } else {
                    printError(ErrCode.EMPTY_LIST);
                }
                System.out.println();
            }
            case saveList -> {
                saveUpDownList(input);
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

    public static void addContFromFile (Scanner input) {
        File file;
        ErrCode error = ErrCode.CORRECT;
        int number = 0;
        String numberStr = "";
        String name = "";
        String nameBuf;

        file = fileReading(input);
        try (Scanner scanFile = new Scanner(file)) {
            while ((error == ErrCode.CORRECT)) {
                nameBuf = scanFile.nextLine();
                if ((nameBuf.length() > 15) || (nameBuf.isEmpty())){
                    error = ErrCode.INPUT_ERR;
                } else {
                    name = nameBuf;
                }
                if (error == ErrCode.CORRECT) {
                    numberStr = scanFile.nextLine();
                    if ((numberStr.length() != 9) || (numberStr.isEmpty())) {
                        error = ErrCode.INPUT_ERR;
                    } else {
                        try {
                            number = Integer.parseInt(numberStr);
                        } catch (NumberFormatException e) {
                            error = ErrCode.INPUT_ERR;
                        }
                    }
                }
                if (error == ErrCode.CORRECT) {
                    addNewContact(name, numberStr);
                    System.out.println("Контакт добавлен успешно.");
                }

            }
        } catch (Exception e) {
            printError(ErrCode.NOT_READABLE);
        }
    }
    public static void deleteContact (Scanner input) {
        int place = 0;
        if (countOfContacts == 0) {
            printError(ErrCode.EMPTY_LIST);
        } else {
            System.out.print("Введите порядковый номер контакта, который хотите удалить (" + countOfContacts + "): ");
            place = getNumConsole(input, 1, countOfContacts);
            deleteContactFromList(place - 1);
            System.out.println("Контакт успешно удалён.\n");
        }
    }
    public static void printError (ErrCode error) {
        System.out.println("\n" + ERRORS[error.ordinal()] + "\nПовторите попытку\n");
    }
    public static void createContact(Scanner input) {
        String number;
        String name;
        name = getNameConsole(input, 15);
        number = getNumberConsole(input);
        addNewContact(name, number);
        System.out.println("Контакт добавлен.\n");
    }
    public static String  getNumberConsole (Scanner input) {
        int number = 0;
        String numberStr;
        ErrCode error;
        do {
            error = ErrCode.CORRECT;
            System.out.print("Введите номер телефона начная с кода: ");
            numberStr = (input.nextLine());
            if (numberStr.length() == 9) {
                try {
                   number = Integer.parseInt(numberStr);
                } catch (NumberFormatException e){
                    error = ErrCode.INPUT_ERR;
                }
            } else {
                error = ErrCode.INPUT_ERR;
            }
            if (error != ErrCode.CORRECT) {
                printError(error);
            }
        } while (error != ErrCode.CORRECT);
        return numberStr;
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
                System.err.printf(ERRORS[err.ordinal()], MIN, MAX);
                System.out.println("\nВведите снова");
            }
        } while (err != ErrCode.CORRECT);
        return numberArr[0];
    }
    static String getNameConsole(Scanner input, final int MAX) {
        ErrCode error;
        String name;
        do {
            error = ErrCode.CORRECT;
            System.out.print("Введите имя от 1 до " + MAX + " символов: ");
            name = input.nextLine();
            if (name.length() > MAX) {
                error = ErrCode.INPUT_ERR;
                printError(error);
            }
        } while (error != ErrCode.CORRECT);
        return name;
    }
    static ChooseAction getChoice(Scanner input) {
        int choice;
        int maxChoice = ChooseAction.values().length - 1;
        choice = getNumConsole(input, 0, maxChoice);
        return ChooseAction.values()[choice];
    }
    public static String readPath (Scanner inputScanner) {
        String pathTofile = "";
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
        String pathToFile = "";
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
    static class DoubleLinkedList {
        String name;
        String number;
        DoubleLinkedList next;
        DoubleLinkedList prev;
    }
    static DoubleLinkedList head = null;
    static DoubleLinkedList tail = null;
    static int countOfContacts = 0;
    static void addNewContact (String name, String number) {
        DoubleLinkedList newCont = new DoubleLinkedList();
        newCont.name = name;
        newCont.number = number;
        newCont.next = null;
        newCont.prev = tail;
        if (head == null) {
            head = newCont;
        } else {
            tail.next = newCont;
        }
        tail = newCont;
        countOfContacts++;
    }
    static void deleteContactFromList(int place) {
        DoubleLinkedList currCont = head;
        DoubleLinkedList nextCont = new DoubleLinkedList();
        DoubleLinkedList prevCont = new DoubleLinkedList();

        int counter = 1;
        while (counter < place) {
            currCont = currCont.next;
            counter++;
        }

        prevCont = currCont.prev;
        nextCont = currCont.next;

        if (prevCont != null) {
            prevCont.next = nextCont;
        } else {
            head = nextCont;
        }

        if (nextCont != null) {
            nextCont.prev = prevCont;
        } else {
            tail = currCont.prev;
        }
        currCont = null;
        countOfContacts--;
    }
    static void printUpDownListConsole () {
        DoubleLinkedList currCont = head;
        int i = 1;
        while (currCont != null) {
            System.out.print(i + ". " + currCont.name + " ");
            System.out.println("+375" + currCont.number);
            currCont = currCont.next;
            i++;
        }
    }
    static void printDownUpListConsole () {
        DoubleLinkedList currCont = tail;
        int i = countOfContacts;
        while (currCont != null) {
            System.out.print(i + ". " + currCont.name + " ");
            System.out.println("+375" + currCont.number);
            currCont = currCont.prev;
            i--;
        }
    }
    static void saveUpDownList (Scanner inputScanner) {
        File file;
        DoubleLinkedList currCont = head;
        int i = 1;
        if (countOfContacts == 0) {
            printError(ErrCode.EMPTY_LIST);
        } else {
            file = fileWriting(inputScanner);
            try (FileWriter writer = new FileWriter(file, true)) {
                while (currCont != null) {
                    writer.write(i + ". " + currCont.name + " ");
                    writer.write("+375" + currCont.number + "\n");
                    currCont = currCont.next;
                    i++;
                }
                System.out.println("Контакты сохранены успешно.\n");
            } catch (Exception e) {
                printError(ErrCode.NOT_WRITEABLE);
            }

        }
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

