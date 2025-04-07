namespace Lab3;

public partial class Form1 : Form
{
    private const int Points = 10000; // Количество точек
    private const double ScaleFactor = 400; // Масштабирование графика
    private const double Coefficient = 1.63; // Коэффициент деления ширины
    private const int ShiftLeft = 0; // Смещение первой группы
    private const int ShiftRight = 200; // Смещение второй группы
    private const double IntersectionThreshold = 0.00000001; // Порог пересечения

    
    private readonly Random _randomizer;
    
    public Form1()
    {
        _randomizer = new Random();
        InitializeComponent();
    }

    private void tb_firstProbability_KeyPress(object sender, KeyPressEventArgs e)
    {
        if (e.KeyChar == (char)Keys.Enter)
        {
            HandleProbabilityChange();
        }
    }

    private void HandleProbabilityChange()
    {
        if (double.TryParse(tb_firstProbability.Text, out double firstProbability))
        {
            if (0 < firstProbability && firstProbability <= 1)
            {
                tb_secondProbability.Text = (1.0 - firstProbability).ToString();
            }
            else
            {
                MessageBox.Show("Число должно быть в диапазоне от 0 до 1", "Осторожно!", MessageBoxButtons.OK);
            }
        }
        else
        {
            MessageBox.Show("Данные должны быть действительным числом", "Осторожно!", MessageBoxButtons.OK);
        }
    }

    private void btn_calculate_Click(object sender, EventArgs e)
    {
        HandleProbabilityChange();
        
        // получаем априорные вероятности
        double prioriProbability1 =  Convert.ToDouble(tb_firstProbability.Text);
        double prioriProbability2 =  Convert.ToDouble(tb_secondProbability.Text);
        
        // генерируем точки
        int correctionSide = (int)(pb_canvas.Width / Coefficient);
        double[] points1 = GeneratePoints(ShiftLeft, correctionSide);
        double[] points2 = GeneratePoints(ShiftRight, correctionSide + ShiftRight);
        
        // считаем мат ожидание
        double mathExpectation1 = CalculateMathExpectation(points1);
        double mathExpectation2 = CalculateMathExpectation(points2);
        
        // считаем среднюю квадратичную
        double sigma1 = CalculateSigma(points1, mathExpectation1);
        double sigma2 = CalculateSigma(points2, mathExpectation2);
        
        double[] probabilityDensity1 = new double[pb_canvas.Width];
        double[] probabilityDensity2 = new double[pb_canvas.Width];
        
        // просчитываем вероятности, для построения графика
        for (int i = 0; i < pb_canvas.Width; i++)
        {
            probabilityDensity1[i] = CalculateProbability(-ShiftLeft + i, mathExpectation1, sigma1) * prioriProbability1;
            probabilityDensity2[i] = CalculateProbability(-ShiftLeft + i, mathExpectation2, sigma2) * prioriProbability2;
        }

        // находим точку пересечения
        int intersectionIndex = FindIntersectionIndex(probabilityDensity1, probabilityDensity2);
        
        // просчитываем ошибки
        double[] errors = CalculateErrors(probabilityDensity1, probabilityDensity2, intersectionIndex);
        
        // выводим на экран
        tb_falseAlarmProbability.Text = errors[0].ToString();
        tb_missingErrorProbability.Text = errors[1].ToString();
        tb_cumulativeErrorProbability.Text = errors[2].ToString();

        DrawChart(probabilityDensity1, probabilityDensity2, intersectionIndex);
    }

    private void DrawChart(double[] probabilityDensity1, double[] probabilityDensity2, int intersectionIndex)
    {
        if (pb_canvas.Width == 0 || pb_canvas.Height == 0) return;

        const int OffsetX = 20; // Смещение графика и осей влево
        const int OffsetY = 20; // Смещение графика вниз

        Bitmap bmp = new Bitmap(pb_canvas.Width, pb_canvas.Height);
        using (Graphics g = Graphics.FromImage(bmp))
        {
            g.Clear(Color.White);

            Pen penClass1 = new Pen(Color.Blue, 2);
            Pen penClass2 = new Pen(Color.Orange, 2);
            Pen penIntersection = new Pen(Color.Red, 2);
            Pen axisPen = new Pen(Color.Black, 2); // Чёрные оси

            double scaleY = (pb_canvas.Height - OffsetY * 2) * ScaleFactor; // Учитываем отступ сверху и снизу

            // Рисуем графики с отступом
            for (int x = 1; x < pb_canvas.Width - OffsetX; x++)
            {
                int y1Prev = pb_canvas.Height - OffsetY - (int)(probabilityDensity1[x - 1] * scaleY);
                int y1 = pb_canvas.Height - OffsetY - (int)(probabilityDensity1[x] * scaleY);
                g.DrawLine(penClass1, x - 1 + OffsetX, y1Prev, x + OffsetX, y1);

                int y2Prev = pb_canvas.Height - OffsetY - (int)(probabilityDensity2[x - 1] * scaleY);
                int y2 = pb_canvas.Height - OffsetY - (int)(probabilityDensity2[x] * scaleY);
                g.DrawLine(penClass2, x - 1 + OffsetX, y2Prev, x + OffsetX, y2);
            }

            // Отрисовка точки пересечения с учётом отступов
            g.DrawLine(penIntersection, intersectionIndex + OffsetX, 0, intersectionIndex + OffsetX,
                pb_canvas.Height - OffsetY);
            g.FillEllipse(Brushes.Green, intersectionIndex + OffsetX - 4,
                pb_canvas.Height - OffsetY - (int)(probabilityDensity2[intersectionIndex] * scaleY) - 4, 8, 8);
            
            // Рисуем оси X и Y с отступами
            g.DrawLine(axisPen, OffsetX, pb_canvas.Height - OffsetY, pb_canvas.Width,
                pb_canvas.Height - OffsetY); // Ось X
            g.DrawLine(axisPen, OffsetX, pb_canvas.Height - OffsetY, OffsetX, 0); // Ось Y
        }

        pb_canvas.Image = bmp;
    }

    private void tb_firstProbability_TextChanged(object sender, EventArgs e)
    {
        btn_calculate.Enabled = !string.IsNullOrWhiteSpace(tb_firstProbability.Text);
    }
    
    private double[] GeneratePoints(int min, int max)
    {
        double[] points = new double[Points];
        
        // генерируем точки
        for (int i = 0; i < Points; i++)
        {
            points[i] = _randomizer.Next(min, max - 50);
        }
        
        return points;
    }
    
    private double CalculateMathExpectation(double[] points) =>
        points.Sum() / points.Length;

    private double CalculateSigma(double[] points, double mathExpectation) =>
        Math.Sqrt(points.Select(probability => Math.Pow(probability - mathExpectation, 2)).Sum() /
                  points.Length);

    private double CalculateProbability(double point, double mathExpectation, double sigma)
    {
        double top = Math.Exp(-0.5 * Math.Pow((point - mathExpectation) / sigma, 2));
        double bottom = sigma * Math.Sqrt(2 * Math.PI);
        return top / bottom;
    }
    
    private int FindIntersectionIndex(double[] probabilityDensity1, double[] probabilityDensity2)
    {
        int intersectionPointIndex = -1;
        double minDifferenct = double.MaxValue;

        for (int i = 0; i < pb_canvas.Width * 0.7; i++)
        {
            double difference = Math.Abs(probabilityDensity1[i] - probabilityDensity2[i]);
            if (difference < minDifferenct)
            {
                minDifferenct = difference;
                intersectionPointIndex = i;
            }
        }
        return intersectionPointIndex;
    }

    private double[] CalculateErrors(double[] probabilityDensity1, double[] probabilityDensity2, int intersectionPointIndex)
    {
        double error1 = probabilityDensity2.Take(intersectionPointIndex).Sum();
        double error2 = probabilityDensity1.Skip(intersectionPointIndex).Sum();

        return
        [
            error1,
            error2,
            error1 + error2
        ];
    }
    
}