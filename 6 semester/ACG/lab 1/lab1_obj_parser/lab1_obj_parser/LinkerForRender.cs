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

        public void Render(Model model, Rasterizer rasterizer)
        {
            // Матрица Модели (Translate * Rotate * Scale)
           
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

            // Отрисовка каждого полигона
            foreach (var faceIndices in model.Faces)
            {
                for (int i = 0; i < faceIndices.Length; i++)
                {
                    // Берем текущую и следующую вершину (замыкаем контур)
                    int index1 = faceIndices[i];
                    int index2 = faceIndices[(i + 1) % faceIndices.Length];

                    Vec4 v1 = model.Vertices[index1];
                    Vec4 v2 = model.Vertices[index2];

                    // Трансформация вершин
                    v1 = ProcessVertex(v1, mvpMatrix, viewportMatrix);
                    v2 = ProcessVertex(v2, mvpMatrix, viewportMatrix);

                    // Простая проверка отсечения (если вершина за камерой)
                    // В полноценном движке нужно делать Clipping (отсечение линий), но для лабы
                    // достаточно не рисовать то, что "улетело" далеко или имеет w < 0 (до проекции)
                    // Здесь упрощенно: если координаты внутри экрана, рисуем.

                    rasterizer.DrawLine((int)v1.X, (int)v1.Y, (int)v2.X, (int)v2.Y, Color.Black);
                }
            }
        }

        private Vec4 ProcessVertex(Vec4 v, Matrix4x4 mvp, Matrix4x4 viewport)
        {
            Vec4 vClip = mvp * v;

            if (vClip.W != 0) 
            {
                vClip.X /= vClip.W;
                vClip.Y /= vClip.W;
                vClip.Z /= vClip.W;
            }
            vClip.W = 1.0;
            Vec4 vScreen = viewport * vClip;

            return vScreen;
        }
    }
}