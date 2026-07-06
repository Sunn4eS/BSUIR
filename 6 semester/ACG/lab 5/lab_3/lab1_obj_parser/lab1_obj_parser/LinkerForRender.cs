using System;

namespace lab1_obj_parser
{
    public class LinkerForRender
    {
        public int Width { get; set; }
        public int Height { get; set; }
        public Vec4 ModelPosition { get; set; } = new Vec4(0, 0, 0);
        public Vec4 ModelRotation { get; set; } = new Vec4(0, 0, 0);
        public Vec4 ModelScale { get; set; } = new Vec4(1, 1, 1);
        public Vec4 CameraPosition { get; set; } = new Vec4(0, 0, 5);
        public bool EnableSSR { get; set; } = true; 

        public Texture DiffuseMap, NormalMap, SpecularMap;

        Vec4 lightDir = new Vec4(0.5, 2, -0.3).Normalize();

        public LinkerForRender(int width, int height) { Width = width; Height = height; }

        public void Render(Model model, Rasterizer rasterizer)
        {
            rasterizer.Clear();
            rasterizer.DiffuseMap = DiffuseMap;
            rasterizer.NormalMap = NormalMap;
            rasterizer.SpecularMap = SpecularMap;

            Matrix4x4 modelMatrix = Matrix4x4.Scale(ModelScale.X, ModelScale.Y, ModelScale.Z)
                                  * Matrix4x4.RotateX(ModelRotation.X)
                                  * Matrix4x4.RotateY(ModelRotation.Y)
                                  * Matrix4x4.RotateZ(ModelRotation.Z)
                                  * Matrix4x4.Translation(ModelPosition.X, ModelPosition.Y, ModelPosition.Z);

            rasterizer.ModelMatrix = modelMatrix;

            Matrix4x4 viewMatrix = Matrix4x4.LookAt(CameraPosition, new Vec4(0, 0, 0), new Vec4(0, 1, 0));
            Matrix4x4 projectionMatrix = Matrix4x4.Perspective(Math.PI / 4, (double)Width / Height, 0.1, 100.0);
            Matrix4x4 viewportMatrix = Matrix4x4.Viewport(Width, Height);

            foreach (var face in model.Faces)
            {
                if (face.Length < 3) continue;

                for (int i = 1; i < face.Length - 1; i++)
                {
                    int v1Idx = face[0][0], t1Idx = face[0][1], n1Idx = face[0][2];
                    int v2Idx = face[i][0], t2Idx = face[i][1], n2Idx = face[i][2];
                    int v3Idx = face[i + 1][0], t3Idx = face[i + 1][1], n3Idx = face[i + 1][2];

                    Vec4 p1 = modelMatrix * model.Vertices[v1Idx];
                    Vec4 p2 = modelMatrix * model.Vertices[v2Idx];
                    Vec4 p3 = modelMatrix * model.Vertices[v3Idx];

                    Vec4 n1 = n1Idx != -1 ? (modelMatrix * model.Normals[n1Idx]).Normalize() : new Vec4(0, 0, 1);
                    Vec4 n2 = n2Idx != -1 ? (modelMatrix * model.Normals[n2Idx]).Normalize() : new Vec4(0, 0, 1);
                    Vec4 n3 = n3Idx != -1 ? (modelMatrix * model.Normals[n3Idx]).Normalize() : new Vec4(0, 0, 1);

                    Vec2 uv1 = t1Idx != -1 ? model.UVs[t1Idx] : new Vec2(0, 0);
                    Vec2 uv2 = t2Idx != -1 ? model.UVs[t2Idx] : new Vec2(1, 0);
                    Vec2 uv3 = t3Idx != -1 ? model.UVs[t3Idx] : new Vec2(0, 1);

                    Vec4 c1 = projectionMatrix * viewMatrix * p1;
                    Vec4 c2 = projectionMatrix * viewMatrix * p2;
                    Vec4 c3 = projectionMatrix * viewMatrix * p3;

                    if (c1.W < 0.001 || c2.W < 0.001 || c3.W < 0.001) continue;

                    Vec4 s1 = PerspectiveDivide(c1, viewportMatrix);
                    Vec4 s2 = PerspectiveDivide(c2, viewportMatrix);
                    Vec4 s3 = PerspectiveDivide(c3, viewportMatrix);

                    double normalZ = (s2.X - s1.X) * (s3.Y - s1.Y) - (s2.Y - s1.Y) * (s3.X - s1.X);
                    if (normalZ >= 0) continue;

                    rasterizer.DrawTriangle(s1, s2, s3, n1, n2, n3, p1, p2, p3, uv1, uv2, uv3, CameraPosition, lightDir);
                }
            }

            if (EnableSSR)
            {
                Matrix4x4 viewProjMatrix = projectionMatrix * viewMatrix;
                rasterizer.ApplySSR(viewProjMatrix, viewportMatrix, CameraPosition);
            }
        }

        private Vec4 PerspectiveDivide(Vec4 vClip, Matrix4x4 viewport)
        {
            double w = vClip.W;
            vClip.X /= w; vClip.Y /= w; vClip.Z /= w; vClip.W = 1.0;
            Vec4 res = viewport * vClip;
            res.W = w;
            return res;
        }
    }
}