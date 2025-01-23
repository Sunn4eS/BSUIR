import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        final int MINNUMOFEL = 0;
        final int MAXNUMOFEL = 100;
        final int MINEL = -300;
        final int MAXEL = 300;
        float prod;
        int numOfEl = 0;
        boolean isIncorrect;

        System.out.println("Данная программа вычисляет произведение жлементов массива с N элементов:\n\n");

        do {
            isIncorrect = false;
            System.out.print("Введите количство элементов [0; 100]:\n");
            try {
                numOfEl = Integer.parseInt(in.nextLine());
            } catch (NumberFormatException e) {
                System.out.print("Проверьте корректность ввода данных!\n");
                isIncorrect = true;
            }
            if ( !isIncorrect && ((numOfEl < MINNUMOFEL) || (numOfEl > MAXNUMOFEL))) {
                System.out.print("Значение не попадает в диапазон!\n");
                isIncorrect = true;
            }
        } while (isIncorrect);

        float[] arr = new float[numOfEl];
        for (int i = 0; i < numOfEl; i++){
            do {
                isIncorrect = false;
                System.out.print("Введите элемент массива [-300; 300]:\n");
                try {
                    arr[i] = Float.parseFloat(in.nextLine());
                } catch (NumberFormatException e) {
                    System.out.print("Проверьте корректность ввода данных!\n");
                    isIncorrect = true;
                }
                if (!isIncorrect && ((arr[i] < MINEL) || (arr[i] > MAXEL))) {
                    System.out.print("Значение не попадает в диапазон!\n");
                    isIncorrect = true;
                }
            } while (isIncorrect);
        }
        prod = arr[0];
        for (int i = 0; i < numOfEl; i++){
            prod *= arr[i];
        }

        System.out.print("Произведение = " + prod);
        in.close();
    }
}