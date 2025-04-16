namespace Lab6.models;

public class Group(int id, List<Distance> distances)
{
    // свойства
    public List<Distance> Distances => distances;
    public int Id { get; init; } = id;

    public Group? ParentGroup1 { get; init; } = null;
    public Group? ParentGroup2 { get; init; } = null;

    public void AddDistance(Distance distance)
    {
        distances.Add(distance);
    }

    public void RemoveDistance(Distance distance)
    {
        distances.Remove(distance);
    }
}