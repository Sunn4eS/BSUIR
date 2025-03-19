namespace k_middle;

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
