using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Media;

namespace Syntax
{
    public class Element
    {
        public Element(ElementType elementType)
        {
            ElementType = elementType;
            Lines = new List<Line>();
        }

        public Element(ElementType elementType, Line line)
        {
            ElementType = elementType;
            Lines = new List<Line> {line};
            StartPosition = new Point(Math.Min(line.From.X, line.To.X),
                Math.Max(line.From.Y, line.To.Y));
            EndPosition = new Point(Math.Max(line.From.X, line.To.X),
                Math.Min(line.From.Y, line.To.Y));
        }

        public Element(ElementType elementType, IEnumerable<Line> lines, Point startPoint,
            Point endPoint)
        {
            StartPosition = startPoint;
            EndPosition = endPoint;
            ElementType = elementType;
            Lines = lines;
        }

        public ElementType ElementType { get; private set; }
        public Point StartPosition { get; private set; }
        public Point EndPosition { get; private set; }
        public IEnumerable<Line> Lines { get; private set; }

        public double Length => Math.Abs(EndPosition.X - StartPosition.X);

        public double Height => Math.Abs(EndPosition.Y - StartPosition.Y);

        public void ScaleTransform(double xScale, double yScale)
        {
            var delta = EndPosition - StartPosition;
            delta.X *= xScale;
            delta.Y *= yScale;
            EndPosition = StartPosition + delta;
            foreach (var line in Lines)
            {
                line.ScaleTransform(xScale, yScale, StartPosition);
            }
        }

        public void ShiftTransform(double xDelta, double yDelta)
        {
            var shift = new Vector(xDelta, yDelta);
            StartPosition += shift;
            EndPosition += shift;
            foreach (var line in Lines)
            {
                line.ShiftTransform(xDelta, yDelta);
            }
        }

        public GeometryGroup GetGeometryGroup()
        {
            var result = new GeometryGroup();
            foreach (var line in Lines)
            {
                result.Children.Add(new LineGeometry(GetScreenPoint(line.From),
                    GetScreenPoint(line.To)));
            }

            return result;
        }

        private Point GetScreenPoint(Point point)
        {
            return new Point(point.X, StartPosition.Y - point.Y);
        }
    }
}