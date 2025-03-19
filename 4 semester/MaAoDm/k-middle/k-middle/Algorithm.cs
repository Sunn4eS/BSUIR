namespace k_middle;

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