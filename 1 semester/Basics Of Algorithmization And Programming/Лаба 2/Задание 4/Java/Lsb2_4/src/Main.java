import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
public class Main {
    public static final int MIN_LENGTH = 2;
    public static final int MAX_LENGTH = 1000;
    public static final int MIN_ELEMENT = -10000;
    public static final int MAX_ELEMENT = 10000;

    public static Scanner scanConsole = new Scanner(System.in);
    public static Scanner scanFile;
    public static File file;
    public static void printTask() {
        System.out.println("Данная программа проверяет невозрастающая ли последовательность:\n");
    }
    public static boolean chooseFileInput() {
        int isFileInput;
        boolean isCorrect, choose;
        isFileInput = 0;
        choose = true;
        do {
            System.out.println("Вы хотите вводить последовательность через файл? (Да - " + 1 + " / Нет - " + 0 + ")");
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
            System.out.println("Введите путь к файлу с расширением .txt с последовательностью, у которой количество членов должно быть не меньше " + MAX_LENGTH + " и не больше " + MIN_LENGTH +  " а элементы должны быть в диапазоне [" + MAX_ELEMENT + " : " + MAX_ELEMENT + "]:" );
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
        int numOfElements;
        int element;
        boolean isCorrect;
        isCorrect = true;
        element = 0;
        numOfElements = 0;
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {
            try {
                numOfElements = scanFile.nextInt();
            } catch (NumberFormatException r) {
                System.out.println("Некорректный тип данных внутри файла!");
                isCorrect = false;
            }
            if (isCorrect) {
                if (!scanFile.hasNextLine()) {
                    isCorrect = false;
                    System.out.println("Длины не равны");
                }
            }
            if (isCorrect)
                isCorrect = checkArea(numOfElements, MIN_LENGTH, MAX_LENGTH);
            scanFile.nextLine();
            while (isCorrect && scanFile.hasNextInt()) {
                try {
                    element = scanFile.nextInt();
                } catch (NumberFormatException r) {
                    System.out.println("Некорректный тип данных внутри файла!");
                    isCorrect = false;
                }
                if (isCorrect)
                    isCorrect = checkArea(element, MIN_ELEMENT, MAX_ELEMENT);
            }
        }
        scanFile.close();
        return isCorrect;
    }

    public static boolean isOrdersEqual() {
        int length;
        int element;
        int numOfElements;
        boolean isCorrect;
        numOfElements = 0;
        length = 0;
        element = 0;
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        numOfElements = scanFile.nextInt();
        isCorrect = true;
        scanFile.nextLine();
        while (isCorrect && scanFile.hasNext()) {
            element = scanFile.nextInt();
            length++;
            isCorrect = checkArea(length, 0, MAX_LENGTH);
            if (length > numOfElements)
                isCorrect = false;
        }
        scanFile.close();
        if (isCorrect && (numOfElements != length))
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

    public static int readFileLengthOfArr() {
        int numOfElements;
        numOfElements = 0;
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        numOfElements = scanFile.nextInt();
        scanFile.close();
        return numOfElements;
    }
    public static int[] readFileArr(int numOfElements) {
        int[] arr;
        arr = new int[numOfElements];
        try {scanFile = new Scanner(file);} catch (FileNotFoundException e) {}
        scanFile.nextLine();
        for (int num = 0;  num < numOfElements; num++)
                arr[num] = scanFile.nextInt();
        scanFile.close();
        return arr;
    }
    public static int readConsoleOrder() {
        int numOfElements;
        boolean isCorrect;
        numOfElements = 0;
        do {
            System.out.print("Введите длинну числовой последовательности[" + MIN_LENGTH + " : " + MAX_LENGTH + "]: ");
            isCorrect = true;
            try {
                numOfElements = Integer.parseInt(scanConsole.nextLine());
            } catch (NumberFormatException e) {
                System.out.println("Проверьте корректность ввода данных!");
                isCorrect = false;
            }
            if (isCorrect)
                isCorrect = checkArea(numOfElements, MIN_LENGTH, MAX_LENGTH);
        } while (!isCorrect);
        return numOfElements;
    }
    public static int[] readConsoleMatrix(int numOfElemnts) {
        int[] arr;
        boolean isCorrect;
        arr = new int[numOfElemnts];
        for (int num = 0; num < numOfElemnts; num++)
                do {
                    System.out.print("Введите в " + (num + 1) + " член последовательности [" + MAX_ELEMENT +  " : " + MAX_ELEMENT + "]: ");
                    isCorrect = true;
                    try {
                        arr[num] = Integer.parseInt(scanConsole.nextLine());
                    } catch (NumberFormatException e) {
                        System.out.println("Проверьте корректность ввода данных!");
                        isCorrect = false;
                    }
                    if (isCorrect)
                        isCorrect = checkArea(arr[num], MIN_ELEMENT, MAX_ELEMENT);
                } while (!isCorrect);
        return arr;
    }
    public static int[] readArr() {
        int[] arr;
        int numOfElements;
        if (chooseFileInput()) {
            getFileNormalReading();
            numOfElements = readFileLengthOfArr();
            arr = readFileArr(numOfElements);
        }
        else {
            numOfElements = readConsoleOrder();
            arr = readConsoleMatrix(numOfElements);
        }
        return arr;
    }
    public static boolean isSequenceNonGrowing(int[] arr, int numOfElements) {
        boolean nonGrowing;
        int ind;
        nonGrowing = true;
        ind = 0;
        for (ind = 0; ind < numOfElements - 1; ind++) {
            if (arr[ind] < arr[ind + 1])
                nonGrowing = false;
        }
        return nonGrowing;
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
    public static void printConsoleResult(boolean nonGrowing) {
        if (nonGrowing)
            System.out.print("Полседовательность является невозрастающей");
        else
            System.out.print("Последовательность не соотвествует условию");
    }
    public static void printFileResult(boolean nonGrowing) {
        try {
            FileWriter writer = new FileWriter(file, true);
            if (nonGrowing)
                writer.write("Полседовательность является невозрастающей");
            else
                writer.write("Последовательность не соотвествует условию");
            writer.close();
        } catch (IOException e) {}
    }
    public static void printResult(boolean nonGrowing) {
        if (chooseFileOutput()) {
            getFileNormalWriting();
            printFileResult(nonGrowing);
        }
        else
            printConsoleResult(nonGrowing);
    }
    public static void main(String[] args) {
        boolean nonGrowing;
        int numOfElements;
        int[] arr;
        nonGrowing = true;
        numOfElements = 0;
        printTask();
        arr = readArr();
        numOfElements = arr.length;
        nonGrowing = isSequenceNonGrowing(arr, numOfElements);
        printResult(nonGrowing);
        scanConsole.close();
    }
}
