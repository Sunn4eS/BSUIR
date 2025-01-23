     import java.util.Scanner;

    public class Main {
        public static void main(String[] args) {

            final int MIN_EPS = 0;
            final int MAX_EPS = 1;
            final int MIN_X = -1;
            final int MAX_X = 1;
            float eps = 0;
            float x = 0;
            boolean isCorrect;

            Scanner in = new Scanner(System.in);

            System.out.println("Данная программа считает значение функции LN(1+X) для введённого значения X, а также подсчитывает количество чисел из ряда Маклорена больших EPS: \n\n");

            isCorrect = true;
            do {
                isCorrect = false;
                System.out.print("Введите число EPS (0; 1): ");
                try {
                    eps = Float.parseFloat(in.nextLine());
                } catch (NumberFormatException e) {
                    System.out.print("Проверьте корректность ввода данных!\n");
                    isCorrect = true;
                }
                if ( !isCorrect && ((eps < MIN_EPS) || (eps > MAX_EPS))) {
                    System.out.print("Значение не попадает в диапазон!\n");
                    isCorrect = true;
                }
            } while (isCorrect);

            isCorrect = true;
            do {
                isCorrect = false;
                System.out.print("Введите число X [-1; 1]: ");
                try {
                    x = Float.parseFloat(in.nextLine());
                } catch (NumberFormatException e) {
                    System.out.print("Проверьте корректность ввода данных!\n");
                    isCorrect = true;
                }
                if ( !isCorrect && ((x < MIN_X) || (x > MAX_X))) {
                    System.out.print("Значение не попадает в диапазон!\n");
                    isCorrect = true;
                }
            } while (isCorrect);
            in.close();

            int i = 1;
            int n = 0;
            float multiple = x;
            float sum = x;

            while (Math.abs(multiple) > eps) {
                i++;
                multiple = -multiple * x;
                sum = sum + multiple / i;
                n++;
            }

            System.out.print("Общая сумма = " + sum + "\n" + "Количество членов ряда = " + n);
        }
    }