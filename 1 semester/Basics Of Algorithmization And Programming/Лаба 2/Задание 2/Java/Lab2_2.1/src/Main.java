import java.util.Scanner;

public class Main {
    static Scanner in = new Scanner(System.in);
    public static void outputTask() {
        System.out.println("Данная программа выясняет можно ли представить N в виде произведения трех последовательных натуральных чисел:\n");
    }

    public static boolean checkRange(int n) {
        final int MIN = 1;
        final int MAX = 100000;
        if  ((n < MIN) || (n > MAX)) {
            return false;
        }
        else {
            return true;
        }
    }

    public static int inputNum() {
        boolean isCorrect = true;
        int n = 0;
        boolean checkRangeN;
        do {
            isCorrect = false;
            System.out.print("Введите число N: ");
            try {
                n = Integer.parseInt(in.nextLine());
            } catch (NumberFormatException e) {
                System.out.print("Проверьте корректность ввода данных!\n");
                isCorrect = true;
            }

            checkRangeN = checkRange(n);

            if (!checkRangeN) {
                System.out.println("Значение не попадает в диапазон!\n");
                isCorrect = true;
            }
        } while (isCorrect);
        return n;
    }

    public static boolean checkMultiplcation(int n) {
        int mult = 0;
        int i = 1;

        while (mult < n) {
            mult = i * (i + 1) * (i + 2);
            i++;
        }
        return n == mult;
    }

    public static void main(String[] args) {
        boolean checkMult;
        outputTask();
        checkMult = checkMultiplcation(inputNum())
        if (checkMult) {
            System.out.println("Можно представить");
        } else {
            System.out.println("Нельзя представить");
        }
        in.close();
    }
}