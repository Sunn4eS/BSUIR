namespace maximin;

public class KMeans : Algorithm
{
    public bool NeedRecalculate;
     public KMeans(IEnumerable<PointF> points, IEnumerable<ClusterDots> clusters)
    {
        Points = new List<PointF>(points);
        Clusters = new List<ClusterDots>(clusters);
    }
    public List<ClusterDots> Learn()
    {
        NeedRecalculate = false;
        ClearClusters();
        AddPointsToCluster();
        ChangeClusterCenters();
        return Clusters;

    }
    void ChangeClusterCenters()
    {
        Parallel.ForEach(Clusters, cluster =>
        {
            var bestCluster = cluster.GetBestClusterCenter();
            if (bestCluster == cluster.Center)
                return;
            
            cluster.Center = bestCluster;
            NeedRecalculate = true;
            
        });
    }

}