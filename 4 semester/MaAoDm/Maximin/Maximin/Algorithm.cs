namespace maximin;

public abstract class Algorithm
{
    protected List<PointF> Points = new();
    protected List<ClusterDots> Clusters = new();

    protected void ClearClusters()
    {
        {
            Clusters.AsParallel().ForAll(x => x.Points = new(){x.Center});
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
    
    ClusterDots? GetMinDifferentCluster(PointF point)
    {
        var minDifferent = double.MaxValue;
        ClusterDots? minDifferentCluster = null;
        foreach (var pointCluster in Clusters)
        {
            if (point == pointCluster.Center) return null;
            var different = ClusterDots.Distance(pointCluster.Center, point);
            if (different < minDifferent)
            {
                minDifferent = different;
                minDifferentCluster = pointCluster;
            }
        }

        return minDifferentCluster;
    }
}