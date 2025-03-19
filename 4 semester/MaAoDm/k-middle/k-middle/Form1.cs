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
            // Инициализация элементов управления
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
                    float size = point == cluster.Center ? 10 : 2;
                    graphics.FillEllipse(
                        new SolidBrush(color),
                        point.X - size/2,
                        point.Y - size/2,
                        size,
                        size);
                }
            }

            pictureBox1.Invoke((MethodInvoker)(() => pictureBox1.Refresh()));
            await Task.CompletedTask;
        }
    }

    public class KMeans : Algorithm
    {
        public bool NeedRecalculate { get; set; }
        readonly Random _random = new();

        public KMeans(IEnumerable<PointF> points, int clustersCount)
        {
            Points = new List<PointF>(points);
            Clusters = InitializeClustersWithRandomCenters(clustersCount);
        }

        private List<ClusterDots> InitializeClustersWithRandomCenters(int count)
        {
            var result = new List<ClusterDots>();
            var selectedCenters = new List<PointF>();
            
            for (int i = 0; i < count; i++)
            {
                PointF point = GetNextRandomCenter();
                selectedCenters.Add(point);
                result.Add(new ClusterDots(point));
            }
            return result;

            PointF GetNextRandomCenter()
            {
                PointF centerCandidate;
                do
                {
                    var index = _random.Next(Points.Count);
                    centerCandidate = Points[index];
                } while (selectedCenters.Contains(centerCandidate));

                return centerCandidate;
            }
        }

        public List<ClusterDots> Learn()
        {
            NeedRecalculate = false;
            ClearClusters();
            AddPointsToCluster();
            ChangeClusterCenters();
            return Clusters;
        }

        private void ChangeClusterCenters()
        {
            Parallel.ForEach(Clusters, cluster =>
            {
                var bestCluster = cluster.GetBestClusterCenter();
                if (bestCluster != cluster.Center)
                {
                    cluster.Center = bestCluster;
                    NeedRecalculate = true;
                }
            });
        }
    }

    public class ClusterDots
    {
        public List<PointF> Points { get; set; } = new();
        public PointF Center { get; set; }

        public ClusterDots(PointF center) => Center = center;

        public PointF GetBestClusterCenter()
        {
            if (Points.Count == 0) return Center;
            
            var bestCenter = new PointF(
                Points.Average(p => p.X),
                Points.Average(p => p.Y));

            float minDistance = float.MaxValue;
            PointF bestPoint = Center;
            
            foreach (var point in Points)
            {
                var distance = Distance(bestCenter, point);
                if (distance < minDistance)
                {
                    minDistance = distance;
                    bestPoint = point;
                }
            }
            return bestPoint;
        }

        public static float Distance(PointF a, PointF b) => 
            (float)Math.Sqrt(Math.Pow(a.X - b.X, 2) + Math.Pow(a.Y - b.Y, 2));
    }

    public abstract class Algorithm
    {
        protected List<PointF> Points = new();
        protected List<ClusterDots> Clusters = new();

        protected void ClearClusters()
        {
            foreach (var cluster in Clusters)
            {
                cluster.Points.Clear();
                cluster.Points.Add(cluster.Center);
            }
        }

        protected void AddPointsToCluster()
        {
            Parallel.ForEach(Points, point =>
            {
                ClusterDots? nearestCluster = null;
                float minDistance = float.MaxValue;

                foreach (var cluster in Clusters)
                {
                    var distance = ClusterDots.Distance(point, cluster.Center);
                    if (distance < minDistance)
                    {
                        minDistance = distance;
                        nearestCluster = cluster;
                    }
                }

                if (nearestCluster != null)
                {
                    lock (nearestCluster.Points)
                    {
                        nearestCluster.Points.Add(point);
                    }
                }
            });
        }
    }
}