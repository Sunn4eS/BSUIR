import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        int numOfMonth = 0;
        boolean isIncorrect;
        final int MIN_MONTH = 1;
        final int MAX_MONTH = 12;
        System.out.print("Данная программа называет месяц года по его номеру.\n");

        do {
            isIncorrect = false;
            System.out.print("Введите номер месяца:\n");
            try {
                numOfMonth = Integer.parseInt(in.nextLine());
            } catch (NumberFormatException e) {
                System.out.print("Проверьте корректность ввода данных!\n");
                isIncorrect = true;
            }
            if ( !isIncorrect && ((numOfMonth < MIN_MONTH) || (numOfMonth > MAX_MONTH))) {
                System.out.print("Значение не попадает в диапазон!\n");
                isIncorrect = true;
            }
        } while (isIncorrect);

        if (numOfMonth < 6 && numOfMonth > 2) {
            System.out.print("Весна");
        }
        if (numOfMonth > 8 && numOfMonth < 12) {
            System.out.print("Осень");
        }
        if (numOfMonth > 5 && numOfMonth < 9) {
            System.out.print("Лето");
        }
        if ((numOfMonth == 12) || (numOfMonth == 1) || (numOfMonth == 2)) {
            System.out.print("Зима");
        }
        in.close();
    }
}