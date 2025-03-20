namespace maximin;

public class ClusterDots
    {
        public List<PointF> Points { get; set; } = new();
        public PointF Center { get; set; }

        public ClusterDots(PointF center) => Center = center;

        public PointF GetBestClusterCenter()
        {
            var bestCenter = new PointF(Points.Average(x => x.X), Points.Average(y => y.Y));
            var minDifferent = double.MaxValue;
            var minDifferentPoint = new PointF();
            foreach (var centerCandidate in Points)
            {
                var different = Distance(bestCenter, centerCandidate);
                if (!(different < minDifferent)) continue;
                minDifferent = different;
                minDifferentPoint = centerCandidate;
            }

            return minDifferentPoint;
        }
        public static float Distance(PointF a, PointF b) => 
            (float)Math.Sqrt(Math.Pow(a.X - b.X, 2) + Math.Pow(a.Y - b.Y, 2));
    }
