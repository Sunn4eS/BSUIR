using System;
using System.Collections.Generic;
using System.Windows;

namespace Syntax
{
    public static class TerminalElementCreator
    {
        private static Dictionary<string, ElementType> _elementTypes;

        private static Dictionary<string, ElementType> ElementTypes => _elementTypes ??= GetTerminalElementTypes();

        public static Dictionary<string, ElementType> GetTerminalElementTypes()
        {
            return new()
            {
                {"a1", new TerminalElementType("a1", new Line(new Point(0, 0), new Point(10, 0)))},
                {"a2", new TerminalElementType("a2", new Line(new Point(0, 0), new Point(0, 10)))},
                {"a3", new TerminalElementType("a3", new Line(new Point(0, 0), new Point(10, 10)))},
                {"a4", new TerminalElementType("a4", new Line(new Point(10, 0), new Point(0, 10)))}
            };
        }

        public static Element GetTerminalElement(Line line)
        {
            var resultName = GetTerminalElementName(line);
            return new Element(ElementTypes[resultName], line);
        }

        private static string GetTerminalElementName(Line line)
        {
            var deltaX = line.From.X - line.To.X;
            var deltaY = line.From.Y - line.To.Y;
            if (Math.Abs(deltaY) < 1) return "a1";
            if (Math.Abs(deltaX) < 1) return "a2";
            if (Math.Abs(deltaX) < 1) return "a2";
            if (Math.Abs(deltaX/deltaY) < 0.2) return "a2";
            if (Math.Abs(deltaY/deltaX) < 0.2) return "a1";
            var highPoint = line.To.Y > line.From.Y ? line.To : line.From;
            var lowPoint = line.To.Y < line.From.Y ? line.To : line.From;
            return highPoint.X < lowPoint.X ? "a4" : "a3";
        }
    }
}