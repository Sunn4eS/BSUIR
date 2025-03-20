using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;

namespace maximin
{
    public class MaximinInitializer
    {
        public List<PointF> Initialize(List<PointF> points, int clusterCount)
        {
            if (points == null || points.Count < clusterCount)
                throw new ArgumentException("Not enough points for clusters");

            var centers = new List<PointF>();
            
            // Первый центроид выбираем случайно
            var random = new Random();
            centers.Add(points[random.Next(points.Count)]);

            // Выбираем остальные центроиды
            for (int i = 1; i < clusterCount; i++)
            {
                var farthestPoint = FindFarthestPoint(points, centers);
                centers.Add(farthestPoint);
            }

            return centers;
        }

        private PointF FindFarthestPoint(List<PointF> points, List<PointF> centers)
        {
            PointF farthestPoint = default;
            float maxMinDistance = 0;

            foreach (var point in points)
            {
                // Находим минимальное расстояние до существующих центроидов
                float minDistance = centers.Min(c => Distance(c, point));
                
                if (minDistance > maxMinDistance)
                {
                    maxMinDistance = minDistance;
                    farthestPoint = point;
                }
            }

            return farthestPoint;
        }

        private float Distance(PointF a, PointF b)
        {
            return (float)Math.Sqrt(Math.Pow(a.X - b.X, 2) + Math.Pow(a.Y - b.Y, 2));
        }
    }
}