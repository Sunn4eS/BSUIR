namespace k_middle;

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