using System;
using System.Collections.Generic;

namespace Syntax
{
    public class UpRule : Rule
    {
        private const int RandomDelta = 3;

        public UpRule(ElementType startElementType, ElementType firstArgumentType,
            ElementType secondArgumentType)
            : base(startElementType, firstArgumentType, secondArgumentType)
        {
        }

        public override string Name => "U";

        public override Element TransformConnect(Element first, Element second)
        {
            MakeSameLength(first, second);
            first.ShiftTransform(0, second.StartPosition.Y + Random.Next(0, 3));
            return Connect(first, second);
        }

        public override Element Connect(Element first, Element second)
        {
            var resultLines = new List<Line>(first.Lines);
            resultLines.AddRange(second.Lines);
            var connect = new Element(StartElementType, resultLines, first.StartPosition,
                second.EndPosition);
            return connect;
        }

        private static void MakeSameLength(Element first, Element second)
        {
            var largestElement = GetLargestElement(first, second);
            var shortestElement = GetShortestElement(first, second);
            if (Math.Abs((double) shortestElement.Length) > 1)
                shortestElement.ScaleTransform(largestElement.Length / shortestElement.Length, 1.0);
        }

        private static Element GetLargestElement(Element first, Element second)
        {
            return first.Length > second.Length ? first : second;
        }

        private static Element GetShortestElement(Element first, Element second)
        {
            return first.Length < second.Length ? first : second;
        }

        public override bool IsRulePare(Element first, Element second)
        {
            if (first.ElementType.Name != FirstArgumentType.Name ||
                second.ElementType.Name != SecondArgumentType.Name) return false;
            return IsRulePositionPare(first, second);
        }

        public override bool IsRulePositionPare(Element first, Element second)
        {
            return second.StartPosition.Y - RandomDelta < first.EndPosition.Y;
        }
    }
}