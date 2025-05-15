using System.Windows;

namespace Syntax
{
    public class Line
    {
        public Line(Point from, Point to)
        {
            From = from;
            To = to;
        }

        public Point From { get; private set; }
        public Point To { get; private set; }

        public void ScaleTransform(double xScale, double yScale, Point centerPoint)
        {
            var length = To - From;
            var startDelta = From - centerPoint;
            startDelta.X *= xScale;
            startDelta.Y *= yScale;
            From = centerPoint + startDelta;
            length.X *= xScale;
            length.Y *= yScale;
            To = From + length;
        }

        public void ShiftTransform(double xDelta, double yDelta)
        {
            var shift = new Vector(xDelta, yDelta);
            To += shift;
            From += shift;
        }
    }
}