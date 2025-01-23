
import java.util.Scanner;
import java.io.File;
import java.io.FileWriter;
public class Main {
    public static final int  MIN_DISK = 1;
    public static final int  MAX_DISK = 25;
    public static int stepCounter = 0;
    public static int[][] steps;


    public enum ERRORS_LIST {
        CORRECT,
        RANGE_ERR,
        NUM_ERR,
        NOT_TXT,
        NOT_EXIST,
        NOT_READABLE,
        NOT_WRITEABLE,
        CHOICE_ERR,
        FILE_EMPTY

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
            "Проверьте корректность выбора!",
            "Файл пуст!",
            "Лишние данные!"
    };
    public static void printTask() {
        System.out.println("Данная программа решает головоломку 'Ханойская башня':\n\n");
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
                number = Integer.parseInt(inputScanner.nextLine());
            else
                number = inputScanner.nextInt();
        } catch (NumberFormatException e) {
            error = ERRORS_LIST.NUM_ERR;
        }
        if (error == ERRORS_LIST.CORRECT && ((number < MIN) || (number > MAX)))
            error = ERRORS_LIST.RANGE_ERR;
        numberArr[0] = error == ERRORS_LIST.CORRECT ? number : 0;
        return error;
    }

    public static int inputOption(Scanner inpuScanner) {
        int option;
        System.out.println("\nВыберете способ ввода данных:");
        System.out.println("Через файл - 1");
        System.out.println("Через консоль - 2");
        option = chooseOption(inpuScanner);

        return option;
    }
    public static int readFileNum (Scanner inputScanner) {
        int disks = 0;
        int[] numArr = new int[1];
        File file;
        ERRORS_LIST error;

        do {
            file = fileReading(inputScanner);
            try (Scanner scanFile = new Scanner(file)) {
                error = readOneNum(scanFile, numArr, MIN_DISK, MAX_DISK, true);
                if (error != ERRORS_LIST.CORRECT) {
                    printError(error);
                } else {
                    disks = numArr[0];
                }
            } catch (Exception e) {
                error = ERRORS_LIST.NOT_READABLE;
                printError(error);
            }

        } while (error != ERRORS_LIST.CORRECT);

        return disks;
    }

    public static int readConsoleNum (Scanner inputScanner) {
        int disks = 0;
        int[] numArr = new int[1];
        ERRORS_LIST error;
        do {
            System.out.print("Введите количество дисков: [" + MIN_DISK + "; " + MAX_DISK + "]: ");
            error = readOneNum(inputScanner, numArr, MIN_DISK, MAX_DISK, false);
            if (error != ERRORS_LIST.CORRECT)
                printError(error);
            else {
                disks = numArr[0];
            }
        } while (error != ERRORS_LIST.CORRECT);
        return disks;
    }

    public static int inputNum(Scanner inputScanner, int option) {
        int disks;
        if (option == 1) {
            disks = readFileNum(inputScanner);
        } else {
            disks = readConsoleNum(inputScanner);
        }
        return disks;
    }
    public static void moveDisk(int fromStick, int toStick, int[][] stepArr) {
        stepArr[stepCounter][0] = fromStick;
        stepArr[stepCounter][1] = toStick;
        stepCounter++;
    }

    public static void hanoiTower(int n, int fromStick, int toStick, int bufStick, int[][] stepArr) {
        if (n > 0) {
            hanoiTower(n - 1, fromStick, bufStick, toStick, stepArr);
            moveDisk(fromStick, toStick, stepArr);
            hanoiTower(n - 1, bufStick, toStick, fromStick, stepArr);
        }
    }

    public static void printResult(Scanner inputScanner, int [][] steps) {
        ERRORS_LIST error;
        File file;
        int option = 0;
        int j = 0;
        int counter = 0;
        System.out.println("\nВыберете способ вывода результата:");
        System.out.println("Через файл - 1");
        System.out.println("Через консоль - 2");

        option = chooseOption(inputScanner);
        if (option == 1)
        {
            file = fileWriting(inputScanner);
            try(FileWriter writer = new FileWriter(file, true)) {
                while (j < steps.length) {
                    counter++;
                    writer.write("\n " +  counter + " шаг: " + "с " + steps[j][0] + " на " + steps[j][1]);
                    j++;
                }

            } catch (Exception e) {
                error = ERRORS_LIST.NOT_WRITEABLE;
                System.out.println(ERRORS[error.ordinal()]);
            }
        } else {
            counter = 0;
            while (j < steps.length) {
                counter++;
                System.out.printf("\n " + counter + " шаг: " + "с " + steps[j][0] + " на " + steps[j][1]);
                j++;
            }
        }
    }


    public static void main(String[] args) {
        Scanner inpScanner = new Scanner(System.in);
        int disks = 0;
        int option;

        printTask();

        option = inputOption(inpScanner);
        disks = inputNum(inpScanner, option);
        steps = new int[(int) (Math.pow(2, disks) - 1)][2];
        hanoiTower(disks, 1, 3,2, steps);

        printResult(inpScanner, steps);
        inpScanner.close();
    }
}
