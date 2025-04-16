namespace Lab5;

public class Potential
{
    private const int MaxIterations = 100;
    
    
    public bool TryLearn(List<List<Point>> classes, out Function result)
    {
        result = new Function(0, 0, 0, 0);
        int correctionCoef = 1;
        for (int i = 0; i < MaxIterations; i++)
        {
            // проходимся 
            bool isTrained = LearnIteration(classes, ref result, ref correctionCoef);
            
            // если коррекции закончились возвращаем результат
            if (!isTrained)
            {
                return true;
            }   
        }
        
        return false;
    }


    private bool LearnIteration(List<List<Point>> classes, ref Function result, ref int correctionCoef)
    {
        bool isLearned = false;
        // проходимся по классам
        for (int classIndex = 0; classIndex < classes.Count; classIndex++)
        {
            // проходимся по объектам
            for (int objectIndex = 0; objectIndex < classes[classIndex].Count; objectIndex++)
            {
                // создаем новую K(X, Xi)
                result += correctionCoef * GetPartialPotentialFunction(classes[classIndex][objectIndex]);
                
                // формируем следующие индекс
                int nextObjectIndex = (objectIndex + 1) % classes[classIndex].Count;
                int nextClassIndex = nextObjectIndex == 0 ? (classIndex + 1) % classes.Count : classIndex;
                
                // считаем значение для K(Xi+1)
                int value = result.GetValue(classes[nextClassIndex][nextObjectIndex]);
                
                // изменяем коэффициент корректировки в соответствии с правилами
                correctionCoef = CoefficientAdjustment(value, nextClassIndex);
                
                // если коэффициент равен 0, то изменений не будет
                if (correctionCoef != 0)
                {
                    isLearned = true;
                }
            }
        }

        return isLearned;
    }
    
    private Function GetPartialPotentialFunction(Point point) => 
        new Function(1, 4 * point.X, 4 * point.Y, 16 * point.X * point.Y);

    private int CoefficientAdjustment(int value, int classIndex)
    {
        // если относится к первому классу и значение меньше 0
        if (classIndex == 0 && value <= 0)
            return 1;
        // если относится ко второму классу и значение больше 0
        if (classIndex == 1 && value > 0)
            return -1;
        
        // если скорректировалось 
        return 0;
    }
}