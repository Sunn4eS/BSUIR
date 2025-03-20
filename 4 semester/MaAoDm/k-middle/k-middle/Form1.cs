using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace k_middle
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
            trackBar2.Minimum = 2;
            trackBar2.Maximum = 20;
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
            int clustersCount = trackBar2.Value;
            int width = pictureBox1.Width - WindowsFrameSize;
            int height = pictureBox1.Height - WindowsFrameSize;

            var points = GenerateRandomPoints(pointsCount, width, height);
            var kMeans = new KMeans(points, clustersCount);

            do
            {
                var result = kMeans.Learn();
                await Draw(result);
                await Task.Delay(50);
            } while (kMeans.NeedRecalculate);
        }

        private List<PointF> GenerateRandomPoints(int pointsCount, int width, int height)
        {
            var points = new List<PointF>(pointsCount);
            Parallel.For(0, pointsCount, i =>
            {
                lock (points)
                {
                    points.Add(new PointF(
                        Random.Next(width),
                        Random.Next(height)));
                }
            });
            return points;
        }

        private async Task Draw(List<ClusterDots> clusters)
        {
            graphics.Clear(Color.White);

            for (int i = 0; i < clusters.Count; i++)
            {
                var cluster = clusters[i];
                var color = Palette[i % Palette.Count];

                foreach (var point in cluster.Points)
                {
                    float size = point == cluster.Center ? 10 : 4;
                    graphics.FillEllipse(
                        new SolidBrush(color),
                        point.X - size / 2,
                        point.Y - size / 2,
                        size,
                        size);
                }
            }

            pictureBox1.Invoke((MethodInvoker)(() => pictureBox1.Refresh()));
            await Task.CompletedTask;
        }

        private void TrackBar_Scroll(object sender, EventArgs e)
        {
            countOfClustersLabel.Text = trackBar2.Value.ToString();
            countOfDotsLabel.Text = trackBar1.Value.ToString();
        }

       
    }
}