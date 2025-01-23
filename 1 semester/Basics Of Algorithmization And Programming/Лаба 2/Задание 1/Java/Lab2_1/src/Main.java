import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        final int MIN = -10000;
        final int MAX = 10000;
        final int MIN_N = 3;
        final int MAX_N = 10000;
        final int LENGTH_OF_ARR = 2;
        int n = 0;
        float vectorMultiplication;
        float prevVectorMultiplication = 0;
        float xTest;
        float maxX;
        float minX;
        float maxY;
        float minY;
        float midX;
        float midY;
        double squareOfFigure = 0;
        boolean isCorrect = true;
        boolean notConvexPolygon = true;
        boolean notOnSameLine = true;
        boolean isCorrectFigure = true;
        boolean sameCoordinate = true;

        System.out.println("Эта программа находит площадь N-угольника:\n");

        do {
            isCorrect = false;
            System.out.print("Введите количество вершин многоугольника [" + MIN_N + "; " + MAX_N + "]: ");
            try {
                n = Integer.parseInt(in.nextLine());
            } catch (NumberFormatException e) {
                System.out.print("Проверьте корректность ввода данных!\n");
                isCorrect = true;
            }
            if ( !isCorrect && ((n < MIN_N) || (n > MAX_N))) {
                System.out.print("Значение не попадает в диапазон!\n");
                isCorrect = true;
            }
        } while (isCorrect);

        float[][] coordinates = new float[n][LENGTH_OF_ARR];

        for (int i = 0; i < n; i++) {

            System.out.println("Введите " + (i + 1) + " пару координат(X, Y)");

            do {
                isCorrect = false;
                System.out.print("Введите X [" + MIN_N + "; " + MAX_N + "]: ");
                try {
                    coordinates[i][0] = Float.parseFloat(in.nextLine());
                } catch (NumberFormatException e) {
                    System.out.print("Проверьте корректность ввода данных!\n");
                    isCorrect = true;
                }
                if (!isCorrect && ((coordinates[i][0] < MIN) || (coordinates[i][0] > MAX))) {
                    System.out.print("Значение не попадает в диапазон!\n");
                    isCorrect = true;
                }
            } while (isCorrect);

            do {
                isCorrect = false;
                System.out.print("Введите Y [" + MIN_N + "; " + MAX_N + "]: ");
                try {
                    coordinates[i][1] = Float.parseFloat(in.nextLine());
                } catch (NumberFormatException e) {
                    System.out.print("Проверьте корректность ввода данных!\n");
                    isCorrect = true;
                }
                if (!isCorrect && ((coordinates[i][1] < MIN) || (coordinates[i][1] > MAX))) {
                    System.out.print("Значение не попадает в диапазон!\n");
                    isCorrect = true;
                }
            } while (isCorrect);
        }

        int i = 0;
        int j = 0;
        while ((i < n) && (sameCoordinate)){
            j = i + 1;
            while ((j < n) && (sameCoordinate)){
                if ((coordinates[i][0] == coordinates[j][0]) && (coordinates[i][1] == coordinates[j][1])){
                    System.out.println("Ошибка! Введенные координаты равны!\n");
                    sameCoordinate = false;
                }
                j++;
            }
            i++;
        }

        float[][] vec = new float[2][2];

        for (i = 0; i < n; i++){
            for (j = i + 2; j < n; j++){
                vec[0][0] = coordinates[(i + 1) % n][0] - coordinates[i % n][0];
                vec[0][1] = coordinates[(i + 1) % n][1] - coordinates[i % n][1];
                vec[1][0] = coordinates[(j + 1) % n][0] - coordinates[j % n][0];
                vec[1][1] = coordinates[(j + 1) % n][1] - coordinates[j % n][1];
                vectorMultiplication = vec[0][0] * vec[1][1] - vec[1][0] * vec[0][1];

                if (vectorMultiplication != 0){
                    xTest = ((coordinates[i % n][0] * vec[0][1] * vec[1][0]) -
                             (coordinates[j % n][0] * vec[1][1] * vec[0][0]) +
                             (vec[1][1] * vec[1][0] * (coordinates[j % n][1]) -
                              coordinates[i % n][1])) / - vectorMultiplication;
                    if ((coordinates[(i + 1) % n][0] - coordinates[i % n][0]) == 0){
                        if (coordinates[(i + 1) % n][0] > coordinates[i % n][0]){
                            maxX = coordinates[(i + 1) % n][0];
                            minX = coordinates[i % n][0];
                        }
                        else{
                            minX = coordinates[(i + 1) % n][0];
                            maxX = coordinates[i % n][0];
                        }
                        if ((xTest > minX) && (xTest < maxX)){
                            isCorrectFigure = false;
                        }
                    }
                    else{
                        if (coordinates[(j + 1) % n][0] > coordinates[j % n][0]){
                            maxX = coordinates[(j + 1) % n][0];
                            minX = coordinates[j % n][0];
                        }
                        else{
                            minX = coordinates[(j + 1) % n][0];
                            maxX = coordinates[j % n][0];
                        }
                        if ((xTest > minX) && (xTest < maxX)){
                            isCorrectFigure = false;
                        }
                    }
                }
            }
        }

        if ((!isCorrectFigure) && (!sameCoordinate)){
            System.out.println("Ошибка! Стороны многоугольника пересекаются!");
        }

        if (isCorrectFigure){
            for (i = 0; i < n; i++){
                vec[0][0] = coordinates[(i + 1) % n][0] - coordinates[i % n][0];
                vec[0][1] = coordinates[(i + 1) % n][1] - coordinates[i % n][1];
                vec[1][0] = coordinates[(i + 2) % n][0] - coordinates[(i + 1) % n][0];
                vec[1][1] = coordinates[(i + 2) % n][1] - coordinates[(i + 1) % n][1];
                vectorMultiplication = vec[0][0] * vec[1][1] - vec[1][0] * vec[0][1];

                if (vectorMultiplication * prevVectorMultiplication < 0){
                    notConvexPolygon = false;
                }
                if (vectorMultiplication == 0){
                    notOnSameLine = false;
                }
                prevVectorMultiplication = vectorMultiplication;
            }
        }

        if ((isCorrectFigure) && (!sameCoordinate)){
            if (!notOnSameLine){
                System.out.println("Ошибка! Стороны многоугольника лежат на одной прямой!\n");
            }
            else if (!notConvexPolygon){
                System.out.println("Многоугольник не является выпуклым");
            }

            maxX = coordinates[0][0];
            minX = coordinates[0][0];
            maxY = coordinates[0][1];
            minY = coordinates[0][1];

            for (i = 0; i < n; i++){
                if (coordinates[i][0] < minX){
                    minX = coordinates[i][0];
                }
                if (coordinates[i][0] > maxX){
                    maxX = coordinates[i][0];
                }
                if (coordinates[i][1] < minY){
                    minY = coordinates[i][1];
                }
                if (coordinates[i][1] > maxY){
                    maxY = coordinates[i][1];
                }
            }
            midX = (minX + maxX) / 2;
            midY = (minY + maxY) / 2;

            for (i = 0; i < n; i++){
                vec[0][0] = coordinates[(i + 1) % n][0] - midX;
                vec[0][1] = coordinates[(i + 1) % n][1] - midY;
                vec[1][0] = coordinates[(i + 2) % n][0] - midX;
                vec[1][1] = coordinates[(i + 2) % n][1] - midY;
                vectorMultiplication = Math.abs(vec[0][0] * vec[1][1] - vec[1][0] * vec[0][1]);
                squareOfFigure = squareOfFigure + ((0.5) * vectorMultiplication);
            }
            if (notOnSameLine && notConvexPolygon){
                System.out.println("Площадь многоугольника =  " + squareOfFigure);
            }
        }
        in.close();
    }
}
