namespace Lab6.models;

public class OxyGroup
{
    public OxyGroup? ParentGroup1 { get; init; } = null;
    public OxyGroup? ParentGroup2 { get; init; } = null;
    
    public int X { get; set; }
    public double Y { get; set; }
    
    public string Name { get; init; } = "";
    public int Id { get; init; }
}
