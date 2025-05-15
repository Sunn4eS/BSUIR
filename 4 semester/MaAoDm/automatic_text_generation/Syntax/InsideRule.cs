using System;
using System.Collections.Generic;

namespace Syntax
{
    public class InsideRule : Rule
    {
        private const int RandomDelta = 3;

        public InsideRule(ElementType startElementType, ElementType firstArgumentType,
            ElementType secondArgumentType)
            : base(startElementType, firstArgumentType, secondArgumentType)
        {
        }

        public override string Name => "I";

        public override Element TransformConnect(Element first, Element second)
        {
            second.ScaleTransform(first.Length/second.Length + 0.5, first.Height/second.Height + 0.5);
            first.ShiftTransform(
                second.StartPosition.X +
                Random.Next(1, (int) (Math.Abs((double) (first.Length - second.Length))*0.8)) -
                first.StartPosition.X,
                second.EndPosition.Y +
                Random.Next(1, (int) (Math.Abs((double) (first.Height - second.Height))*0.8)) -
                first.EndPosition.Y);
            return Connect(first, second);
        }

        public override Element Connect(Element first, Element second)
        {
            var resultLines = new List<Line>(first.Lines);
            resultLines.AddRange(second.Lines);
            var connect = new Element(StartElementType, resultLines, second.StartPosition,
                second.EndPosition);
            return connect;
        }

        public override bool IsRulePare(Element first, Element second)
        {
            if (first.ElementType.Name != FirstArgumentType.Name ||
                second.ElementType.Name != SecondArgumentType.Name) return false;
            return IsRulePositionPare(first, second);
        }

        public override bool IsRulePositionPare(Element first, Element second)
        {
            return first.StartPosition.X > second.StartPosition.X - RandomDelta &&
                   first.StartPosition.Y - RandomDelta < second.StartPosition.Y
                   && first.EndPosition.X - RandomDelta < second.EndPosition.X &&
                   first.EndPosition.Y > second.EndPosition.Y - RandomDelta;
        }
    }
}