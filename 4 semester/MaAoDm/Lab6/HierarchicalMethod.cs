using Lab6.models;

namespace Lab6;

public class HierarchicalMethod
{

    private int _totalGroups;  
    private readonly List<Group> _groups;
    private readonly List<OxyGroup> _oxyGroups;
    private int _numberOfChar;
    private int _xDistance;
    private const int StepDistance = 10;

    public HierarchicalMethod(double[,] distances)
    {
        // создаем группы
        _groups = InitGroups(distances);
        _totalGroups = _groups.Count;
        _numberOfChar = 0;
        _xDistance = 0;
        _oxyGroups = InitOxyGroups(distances);
        
    }

    private List<OxyGroup> InitOxyGroups(double[,] distances)
    {
        var oxyGroups = new List<OxyGroup>();

        for (int i = 0; i < distances.GetLength(0); i++)
        {
            oxyGroups.Add(new OxyGroup() {Name = $"X{i+1}", Id = i});
        }
        
        return oxyGroups;
    }

    private List<Group> InitGroups(double[,] distances)
    {
        List<Group> groups = new();
        int count = distances.GetLength(0);

        for (int i = 0; i < count; i++)
        {
            List<Distance> groupDistances = new List<Distance>();
            
            for (int j = 0; j < count; j++)
            {
                if (i == j) continue;
                
                groupDistances.Add(new Distance(distances[i, j], j));
            }
            
            groups.Add(new Group(i, groupDistances));
        }
        
        return groups;
    }
    
    public OxyGroup Compute()
    {
        while (_groups.Count > 1)
        {
            // находим две группы для следующего мерджа
            var (minDist, firstGroupId, secondGroupId) = GetMergeGroupsId();
            
            // получаем группы
            Group firstGroup = _groups.Find(g => g.Id == firstGroupId)!;
            Group secondGroup = _groups.Find(g => g.Id == secondGroupId)!;
        
            // сливаем две найденные группы
            Group newGroup = MergeGroups(firstGroup, secondGroup);
        
            // удаляем старые группы
            _groups.Remove(firstGroup);
            _groups.Remove(secondGroup);
            
            // добавляем новую группу
            _groups.Add(newGroup);

            // обновляем данные для отрисовки
            UpdateOxyGroups(firstGroupId, secondGroupId, minDist);
            
            // увеличиваем значение количества групп созданных за все время
            _totalGroups++;
        }
        
        return _oxyGroups[^1];
    }

    private void UpdateOxyGroups(int firstGroupId, int secondGroupId, double minDist)
    {
        // получаем для отрисовки найденные группы 
        OxyGroup firstOxyGroup = _oxyGroups.Find(g => g.Id == firstGroupId)!;
        OxyGroup secondOxyGroup = _oxyGroups.Find(g => g.Id == secondGroupId)!;

        // если 1 группа это стартовая точка, то изменяем её x
        if (firstOxyGroup.X == 0)
        {
            _xDistance += StepDistance;
            firstOxyGroup.X = _xDistance;
        }
        
        // если 2 группа это стартовая точка, то изменяем её x
        if (secondOxyGroup.X == 0)
        {
            _xDistance += StepDistance;
            secondOxyGroup.X = _xDistance;
        }
        
        // создаем новую точку, от нового класса
        _oxyGroups.Add(new OxyGroup()
        {
            Name = NextChar().ToString(),
            Id = _totalGroups,
            X = (firstOxyGroup.X + secondOxyGroup.X) / 2,
            Y = minDist,
            ParentGroup1 = firstOxyGroup,
            ParentGroup2 = secondOxyGroup,
        });
        
    }

    private Group MergeGroups(Group firstGroup, Group secondGroup)
    {
        var newGroupDistances = new List<Distance>();
        
        foreach (var group in _groups)
        {
            if (group.Id == firstGroup!.Id || group.Id == secondGroup!.Id) continue;
            
            // высчитываем новый distance
            
            
            // находим минимум среди двух distance
            Distance firstDistance = group.Distances.Find(d => d.TargetId == firstGroup.Id);
            Distance secondDistance = group.Distances.Find(d => d.TargetId == secondGroup.Id);
            
            double minDistance = Math.Min(firstDistance.Value, secondDistance.Value);
            
            // удаляем старые расстояния у текущей группы
            group.RemoveDistance(firstDistance);
            group.RemoveDistance(secondDistance);
            
            
            // добавляем у текущей группы новое расстояние
            group.Distances.Add(new Distance(minDistance,_totalGroups));
            // добавляем у новой группы новое расстояние
            newGroupDistances.Add(new Distance(minDistance, group.Id));
        }
        
        return new Group(_totalGroups, newGroupDistances);
    }

    private (double, int, int) GetMergeGroupsId()
    {
        int firstGroup = -1;
        int secondGroup = -1;
        double minDist = double.MaxValue;
        
        // находим группу по минимальному расстоянию 
        foreach (var group in _groups)
        {
            foreach (var distance in group.Distances)
            {
                if (distance.Value < minDist)
                {
                    minDist = distance.Value;
                    firstGroup = group.Id;
                    secondGroup = distance.TargetId;
                }
            }
        }
        
        return (minDist, firstGroup, secondGroup);
    }
    
    private char NextChar()
    {
        const string alphabet = "ABCDEFGHIKLMNOPQRSTVXYZ";
        _numberOfChar = (_numberOfChar + 1) % alphabet.Length;
        return alphabet[_numberOfChar - 1];
    }
}
