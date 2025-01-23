import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        final int MINDAYS = 0, SECONDDAY = 2, MAXDAY = 1000;
        final float PERCENTAGE = (float) 0.1;
        int numOfDays = 0;
        int i;
        float distancePerDay;
        float totalDistance;
        boolean isIncorrect;
        System.out.println("Данная программа показывает какой суммарный пробег пробежит спортсмен за N дней: \n");

        do {
            isIncorrect = false;
            System.out.print("Введите количество дней:\n");
            try {
                numOfDays = Integer.parseInt(in.nextLine());
            } catch (NumberFormatException e) {
                System.out.print("Проверьте корректность ввода данных!\n");
                isIncorrect = true;
            }
            if ( !isIncorrect && ((numOfDays < MINDAYS) || (numOfDays > MAXDAY))) {
                System.out.print("Значение не попадает в диапазон!\n");
                isIncorrect = true;
            }
        } while (isIncorrect);

        distancePerDay = 10;
        totalDistance = 10;

        for (i = SECONDDAY; i <= numOfDays; i++) {
            distancePerDay = distancePerDay * PERCENTAGE + distancePerDay;
            totalDistance += distancePerDay;
        }

        System.out.print("Общее расстояние: " + totalDistance);
        in.close();
    }
}