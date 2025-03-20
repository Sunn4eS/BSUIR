using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace maximin
{
    public partial class Form1 : Form
    {
        const int WindowsFrameSize = 30;
        List<Color> Palette { get; } = new List<Color>();
        Random Random { get; } = new Random();
        Bitmap canvasBitmap;
        Graphics graphics;

        public Form1()
        {
            InitializeComponent();
            InitializeComponents();
            InitializePalette();
        }

        private void InitializeComponents()
        {
            canvasBitmap = new Bitmap(pictureBox1.Width, pictureBox1.Height);
            pictureBox1.Image = canvasBitmap;
            graphics = Graphics.FromImage(canvasBitmap);
            graphics.Clear(Color.White);

            trackBar1.Minimum = 1000;
            trackBar1.Maximum = 100000;
           }

        private void InitializePalette()
        {
            for (int i = 0; i < 20; i++)
            {
                Palette.Add(Color.FromArgb(
                    Random.Next(256),
                    Random.Next(256),
                    Random.Next(256)));
            }
        }

        private async void Button1_Click(object sender, EventArgs e)
        {
            graphics.Clear(Color.White);
            pictureBox1.Refresh();

            int pointsCount = trackBar1.Value;
            int width = pictureBox1.Width - WindowsFrameSize;
            int height = pictureBox1.Height - WindowsFrameSize;

            var points = GenerateRandomPoints(pointsCount, width, height);
            var maxiMin = new MaxiMin(points);

            (List<ClusterDots> list, PointF? point) result;
            while (true)
            {
                result = maxiMin.Learn();
                if (result.point is null) break;
                await Draw(result.list);
            }

            await Draw(result.list);
            await Task.Delay(1000);

            var kMeans = new KMeans(maxiMin.GetPoints(), maxiMin.GetClusters());
        
            do
            {
                var newResult = kMeans.Learn();
                await Draw(newResult);
            } while (kMeans.NeedRecalculate);


        }

        List<PointF> GenerateRandomPoints(int pointsCount, int width, int height)
        {
            var points = new List<PointF>(pointsCount);
            for (int i = 0; i < pointsCount; i++)
                points.Add(new PointF(Random.Next(width), Random.Next(height)));
            return points;
        }

        private async Task Draw(List<ClusterDots> result)
        {
            // Создаем новый Bitmap с размерами PictureBox
            var bmp = new Bitmap(pictureBox1.Width, pictureBox1.Height);
    
            using (var g = Graphics.FromImage(bmp))
            {
                g.Clear(Color.White);
                g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;

                for (int i = 0; i < result.Count; i++)
                {
                    var cluster = result[i];
                    var color = Palette[i % Palette.Count];

                    // Рисуем все точки кластера
                    foreach (var point in cluster.Points)
                    {
                        var size = point.Equals(cluster.Center) ? 10 : 3;
                        var rect = new RectangleF(
                            point.X - size/2, 
                            point.Y - size/2, 
                            size, 
                            size
                        );
                
                        g.FillEllipse(new SolidBrush(color), rect);
                    }
                }
            }

            // Обновляем PictureBox в UI-потоке
            pictureBox1.Invoke((MethodInvoker)delegate {
                pictureBox1.Image?.Dispose();
                pictureBox1.Image = bmp;
            });

            await Task.Delay(500);
        }

        private void TrackBar_Scroll(object sender, EventArgs e)
        {
            countOfDotsLabel.Text = trackBar1.Value.ToString();
        }

       
    }
}