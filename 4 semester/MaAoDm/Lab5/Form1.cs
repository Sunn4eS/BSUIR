namespace Lab5;

public partial class Form1 : Form
{
    private Function? _function;
    private Painter _painter;
    
    public Form1()
    {
        _function = null;
        InitializeComponent();
        _painter = new Painter(pb_canvas);
    }

    private void btn_findFunction_Click(object sender, EventArgs e)
    {
        Potential potential = new Potential();
        
        List<List<Point>> classes = GetPoints();
        if (potential.TryLearn(classes, out Function result))
        {
            _function = result;
            tb_separatingFunction.Text = _function.ToString();
            
            _painter.Clear();
            _painter.DrawAxes();
            // отрисовка функции
            _painter.DrawFunction(_function);
            // отрисовка точек
            foreach (var points in classes)
            {
                _painter.DrawPoints(points, _function);    
            }
        }
        else
        {
            MessageBox.Show("Невозможно построить разделяющую функцию!", "Йо-йой", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
            _function = null;
        }
    }

    private List<List<Point>> GetPoints()
    {
        var points = new List<List<Point>>();
        points.Add([
            new Point(Convert.ToInt32(tb_x1_1.Text), Convert.ToInt32(tb_y1_1.Text)),
            new Point(Convert.ToInt32(tb_x1_2.Text), Convert.ToInt32(tb_y1_2.Text))
        ]);
        points.Add([
            new Point(Convert.ToInt32(tb_x2_1.Text), Convert.ToInt32(tb_y2_1.Text)),
            new Point(Convert.ToInt32(tb_x2_2.Text), Convert.ToInt32(tb_y2_2.Text))
        ]);
        return points;
    }

    private void tb_learnPoints_TextChanged(object sender, EventArgs e)
    {
        btn_findFunction.Enabled = !(string.IsNullOrWhiteSpace(tb_x1_1.Text) ||
                                     string.IsNullOrWhiteSpace(tb_y1_1.Text) ||
                                     string.IsNullOrWhiteSpace(tb_x1_2.Text) ||
                                     string.IsNullOrWhiteSpace(tb_y1_2.Text) ||
                                     string.IsNullOrWhiteSpace(tb_x2_1.Text) ||
                                     string.IsNullOrWhiteSpace(tb_y2_1.Text) ||
                                     string.IsNullOrWhiteSpace(tb_x2_2.Text) ||
                                     string.IsNullOrWhiteSpace(tb_y2_2.Text));
    }

    private void tb_testObject_TextChanged(object sender, EventArgs e)
    {
        btn_addTestObj.Enabled = !(string.IsNullOrWhiteSpace(tb_test_x.Text) ||
                                   string.IsNullOrWhiteSpace(tb_test_y.Text));
    }

    private void tb_generateCount_TextChanged(object sender, EventArgs e)
    {
        btn_generate.Enabled = !string.IsNullOrWhiteSpace(tb_generateCount.Text);
    }

    private void btn_addTestObj_Click(object sender, EventArgs e)
    {
        if (_function != null)
        {
            Point point = new Point(Convert.ToInt32(tb_test_x.Text), Convert.ToInt32(tb_test_y.Text));
            _painter.DrawPoint(point, _function);
        }
        else
        {
            MessageBox.Show("Сначала найдите разделяющую функцию!", "Йо-йой", 
                MessageBoxButtons.OK, MessageBoxIcon.Asterisk);
        }
        
    }

    private void btn_generate_Click(object sender, EventArgs e)
    {
        if (_function != null)
        {
            int count = Convert.ToInt32(tb_generateCount.Text);
            List<Point> points = GeneratePoints(count);
            _painter.DrawPoints(points, _function);
        }
        else
        {
            MessageBox.Show("Сначала найдите разделяющую функцию!", "Йо-йой", 
                MessageBoxButtons.OK, MessageBoxIcon.Asterisk);
        }
    }

    private List<Point> GeneratePoints(int count)
    {
        List<Point> points = new List<Point>();
        Random random = new Random();

        int minX = -(_painter.CanvasWidth / (2 * Painter.Step));
        int maxX = _painter.CanvasWidth / (2 * Painter.Step);
        int minY = -(_painter.CanvasHeight / (2 * Painter.Step));
        int maxY = _painter.CanvasHeight / (2 * Painter.Step);

        for (int i = 0; i < count; i++)
        {
            int x = random.Next(minX, maxX);
            int y = random.Next(minY, maxY);
            points.Add(new Point(x, y));
        }

        return points;
    }
}