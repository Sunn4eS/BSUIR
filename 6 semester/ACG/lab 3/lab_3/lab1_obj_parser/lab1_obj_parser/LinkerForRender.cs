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
                int v1Idx = faceIndices[0][0];
                int n1Idx = faceIndices[0][1];

                int v2Idx = faceIndices[1][0];
                int n2Idx = faceIndices[1][1];

                int v3Idx = faceIndices[2][0];
                int n3Idx = faceIndices[2][1];

                // 2. Мировые координаты (для освещения)
                Vec4 p1 = modelMatrix * model.Vertices[v1Idx];
                Vec4 p2 = modelMatrix * model.Vertices[v2Idx];
                Vec4 p3 = modelMatrix * model.Vertices[v3Idx];

                // 3. Нормали (из файла или рассчитанные)
                // Примечание: по-хорошему их надо умножать на спец. матрицу нормалей, 
                // но для простоты и без неровного масштаба можно просто modelMatrix
                Vec4 n1 = (n1Idx != -1) ? (modelMatrix * model.Normals[n1Idx]).Normalize() : new Vec4(0, 0, 1);
                Vec4 n2 = (n2Idx != -1) ? (modelMatrix * model.Normals[n2Idx]).Normalize() : new Vec4(0, 0, 1);
                Vec4 n3 = (n3Idx != -1) ? (modelMatrix * model.Normals[n3Idx]).Normalize() : new Vec4(0, 0, 1);

                // 4. Экранные координаты
                Vec4 c1 = projectionMatrix * viewMatrix * p1;
                Vec4 c2 = projectionMatrix * viewMatrix * p2;
                Vec4 c3 = projectionMatrix * viewMatrix * p3;

                if (c1.W < 0.1 || c2.W < 0.1 || c3.W < 0.1) continue;

                Vec4 s1 = PerspectiveDivide(c1, viewportMatrix);
                Vec4 s2 = PerspectiveDivide(c2, viewportMatrix);
                Vec4 s3 = PerspectiveDivide(c3, viewportMatrix);

                // Back-face culling
                double normalZ = (s2.X - s1.X) * (s3.Y - s1.Y) - (s2.Y - s1.Y) * (s3.X - s1.X);
                if (normalZ >= 0) continue;

                // 5. Вызываем наш новый DrawTriangle
                rasterizer.DrawTriangle(s1, s2, s3, n1, n2, n3, p1, p2, p3, CameraPosition, lightDir);
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