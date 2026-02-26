using lab1_obj_parser;
using System;
using System.Drawing;

namespace lab1_obj_parser
{
    public class LinkerForRender
    {
        public int Width { get; set; }
        public int Height { get; set; }

        // Параметры трансформации модели (Model Matrix)
        public Vec4 ModelPosition { get; set; } = new Vec4(0, 0, 0);
        public Vec4 ModelRotation { get; set; } = new Vec4(0, 0, 0); // Углы Эйлера
        public Vec4 ModelScale { get; set; } = new Vec4(1, 1, 1);

        // Параметры камеры (View Matrix)
        public Vec4 CameraPosition { get; set; } = new Vec4(0, 0, 5);
        public Vec4 CameraTarget { get; set; } = new Vec4(0, 0, 0);
        public Vec4 CameraUp { get; set; } = new Vec4(0, 1, 0);

        public LinkerForRender(int width, int height)
        {
            Width = width;
            Height = height;
        }

        private Random _rnd = new Random();

        public void Render(Model model, Rasterizer rasterizer)
        {
            // Матрица Модели (Translate * Rotate * Scale)
            rasterizer.Clear();

            Matrix4x4 matScale = Matrix4x4.Scale(ModelScale.X, ModelScale.Y, ModelScale.Z);
            Matrix4x4 matRotX = Matrix4x4.RotateX(ModelRotation.X);
            Matrix4x4 matRotY = Matrix4x4.RotateY(ModelRotation.Y);
            Matrix4x4 matRotZ = Matrix4x4.RotateZ(ModelRotation.Z);
            Matrix4x4 matTrans = Matrix4x4.Translation(ModelPosition.X, ModelPosition.Y, ModelPosition.Z);

            Matrix4x4 modelMatrix = matTrans * matRotZ * matRotY * matRotX * matScale;
            
            Matrix4x4 viewMatrix = Matrix4x4.LookAt(CameraPosition, CameraTarget, CameraUp);

            // Матрица Проекции
            Matrix4x4 projectionMatrix = Matrix4x4.Perspective(Math.PI / 4, (double)Width / Height, 0.1, 100.0);

            // Матрица Viewport 
            Matrix4x4 viewportMatrix = Matrix4x4.Viewport(Width, Height);

            // MVP = Projection * View * Model
            Matrix4x4 mvpMatrix = projectionMatrix * viewMatrix * modelMatrix;

            // Объединенная матрица VP (View * Projection) - чтобы не умножать лишний раз
            Matrix4x4 vpMatrix = projectionMatrix * viewMatrix;

            Vec4 lightDir = new Vec4(1, 1, 1).Normalize();



            foreach (var faceIndices in model.Faces)
            {
                Vec4 v1World = modelMatrix * model.Vertices[faceIndices[0]];
                Vec4 v2World = modelMatrix * model.Vertices[faceIndices[1]];
                Vec4 v3World = modelMatrix * model.Vertices[faceIndices[2]];

                Vec4 edge1 = v2World - v1World;
                Vec4 edge2 = v3World - v1World;
                
                Vec4 normal = Vec4.Cross(edge1, edge2).Normalize();

                double dot = Vec4.Dot(normal, lightDir);

                if (dot < 0) dot = 0;

                double intensity = 0.3 + (0.7 * dot);

                if (intensity > 1.0) intensity = 1.0;
                Color baseColor = Color.White;

                Color shadedColor = Color.FromArgb(
                    (int)(baseColor.R * intensity),
                    (int)(baseColor.G * intensity),
                    (int)(baseColor.B * intensity)
                );

                Vec4 v1 = model.Vertices[faceIndices[0]];
                Vec4 v2 = model.Vertices[faceIndices[1]];
                Vec4 v3 = model.Vertices[faceIndices[2]];

                Vec4 c1 = mvpMatrix * v1;
                Vec4 c2 = mvpMatrix * v2;
                Vec4 c3 = mvpMatrix * v3;

                if (c1.W < 0.1 || c2.W < 0.1 || c3.W < 0.1) continue;

                Vec4 s1 = PerspectiveDivide(c1, viewportMatrix);
                Vec4 s2 = PerspectiveDivide(c2, viewportMatrix);
                Vec4 s3 = PerspectiveDivide(c3, viewportMatrix);

                // --- ЭТАП 2: ОТБРАКОВКА ЗАДНИХ ГРАНЕЙ (BACK-FACE CULLING) ---
                // Вычисляем векторное произведение двух сторон треугольника на экране
                double ax = s2.X - s1.X;
                double ay = s2.Y - s1.Y;
                double bx = s3.X - s1.X;
                double by = s3.Y - s1.Y;

                double normalZ = ax * by - ay * bx;

                if (normalZ >= 0)
                {
                    continue; 
                }

                rasterizer.DrawTriangle(s1, s2, s3, shadedColor);
            }
        }

        private Vec4 PerspectiveDivide(Vec4 vClip, Matrix4x4 viewport)
        {
            double invW = 1.0 / vClip.W;
            vClip.X *= invW;
            vClip.Y *= invW;
            vClip.Z *= invW;
            vClip.W = 1.0;

            return viewport * vClip;
        }
    }
}