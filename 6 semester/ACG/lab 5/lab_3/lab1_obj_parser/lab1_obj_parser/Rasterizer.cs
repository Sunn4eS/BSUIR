using System;
using System.Runtime.CompilerServices;

namespace lab1_obj_parser
{
    public unsafe class Rasterizer
    {
        private NewBitmap _canvas;
        private float[] _zBuffer;

        private Vec4[] _worldPosBuffer;
        private Vec4[] _worldNormalBuffer;
        private float[] _specularBuffer;
        private int[] _colorBuffer;

        private int _width, _height;

        public Texture DiffuseMap { get; set; }
        public Texture NormalMap { get; set; }
        public Texture SpecularMap { get; set; }
        public Matrix4x4 ModelMatrix { get; set; }

        private readonly float ka = 0.2f, kd = 0.8f, ks = 1.0f;
        private readonly float shininess = 128.0f;

        public Rasterizer(NewBitmap canvas)
        {
            _canvas = canvas; _width = canvas.Width; _height = canvas.Height;
            int length = _width * _height;
            _zBuffer = new float[length];
            _worldPosBuffer = new Vec4[length];
            _worldNormalBuffer = new Vec4[length];
            _specularBuffer = new float[length];
            _colorBuffer = new int[length];
        }

        public void Clear() => Array.Fill(_zBuffer, float.MaxValue);

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public void DrawTriangle(Vec4 v1, Vec4 v2, Vec4 v3,
                                 Vec4 n1, Vec4 n2, Vec4 n3,
                                 Vec4 p1, Vec4 p2, Vec4 p3,
                                 Vec2 uv1, Vec2 uv2, Vec2 uv3,
                                 Vec4 cameraPos, Vec4 lightDir)
        {
            if (v1.Y > v2.Y) { Swap(ref v1, ref v2); Swap(ref n1, ref n2); Swap(ref p1, ref p2); Swap(ref uv1, ref uv2); }
            if (v1.Y > v3.Y) { Swap(ref v1, ref v3); Swap(ref n1, ref n3); Swap(ref p1, ref p3); Swap(ref uv1, ref uv3); }
            if (v2.Y > v3.Y) { Swap(ref v2, ref v3); Swap(ref n2, ref n3); Swap(ref p2, ref p3); Swap(ref uv2, ref uv3); }

            int y1 = (int)v1.Y, y2 = (int)v2.Y, y3 = (int)v3.Y;
            if (y1 == y3) return;

            double invW1 = 1.0 / v1.W, invW2 = 1.0 / v2.W, invW3 = 1.0 / v3.W;

            p1 *= invW1; p2 *= invW2; p3 *= invW3;
            n1 *= invW1; n2 *= invW2; n3 *= invW3;
            uv1 *= invW1; uv2 *= invW2; uv3 *= invW3;

            byte* scan0 = _canvas.GetScan0();
            int stride = _canvas.GetStride();

            for (int y = y1; y <= y3; y++)
            {
                if (y < 0 || y >= _height) continue;
                bool isUpper = y < y2;
                double t1 = (y - y1) / (double)(y3 - y1);
                double t2 = isUpper ? (y - y1) / (double)(y2 - y1 + 1e-6) : (y - y2) / (double)(y3 - y2 + 1e-6);

                Vec4 va = v1 + (v3 - v1) * t1, vb = isUpper ? v1 + (v2 - v1) * t2 : v2 + (v3 - v2) * t2;
                Vec4 pa = p1 + (p3 - p1) * t1, pb = isUpper ? p1 + (p2 - p1) * t2 : p2 + (p3 - p2) * t2;
                Vec4 na = n1 + (n3 - n1) * t1, nb = isUpper ? n1 + (n2 - n1) * t2 : n2 + (n3 - n2) * t2;
                Vec2 uva = uv1 + (uv3 - uv1) * t1, uvb = isUpper ? uv1 + (uv2 - uv1) * t2 : uv2 + (uv3 - uv2) * t2;
                double iWa = invW1 + (invW3 - invW1) * t1, iWb = isUpper ? invW1 + (invW2 - invW1) * t2 : invW2 + (invW3 - invW2) * t2;

                if (va.X > vb.X) { Swap(ref va, ref vb); Swap(ref pa, ref pb); Swap(ref na, ref nb); Swap(ref uva, ref uvb); Swap(ref iWa, ref iWb); }

                int xStart = Math.Max((int)Math.Ceiling(va.X), 0);
                int xEnd = Math.Min((int)Math.Ceiling(vb.X), _width);
                double dx = vb.X - va.X; if (dx < 1e-6) dx = 1.0;

                int offset = y * _width;
                int* row = (int*)(scan0 + (y * stride));

                for (int x = xStart; x < xEnd; x++)
                {
                    double phi = (x - va.X) / dx;
                    float z = (float)(va.Z + (vb.Z - va.Z) * phi);

                    if (z < _zBuffer[offset + x])
                    {
                        _zBuffer[offset + x] = z;

                        double invW = iWa + (iWb - iWa) * phi;
                        double w = 1.0 / invW;

                        Vec4 p = (pa + (pb - pa) * phi) * w;
                        Vec4 n = (na + (nb - na) * phi) * w;
                        Vec2 uv = (uva + (uvb - uva) * phi) * w;

                        Vec4 color = DiffuseMap != null ? DiffuseMap.Sample(uv) : new Vec4(1, 1, 1);

                        if (NormalMap != null)
                        {
                            Vec4 nm = NormalMap.Sample(uv);
                            Vec4 localNorm = new Vec4(nm.X * 2.0 - 1.0, nm.Y * 2.0 - 1.0, nm.Z * 2.0 - 1.0, 0);
                            n = (ModelMatrix * localNorm).Normalize();
                        }
                        else { n = n.Normalize(); }

                        double specStr = SpecularMap != null ? SpecularMap.Sample(uv).X : 0.3;

                        double dotLN = Math.Max(Vec4.Dot(n, lightDir), 0.0);
                        Vec4 viewDir = (cameraPos - p).Normalize();
                        Vec4 reflectDir = Vec4.Reflect(lightDir, n).Normalize();
                        double specBase = Math.Max(Vec4.Dot(reflectDir, viewDir), 0.0);

                        double diffuse = dotLN * kd;
                        double specular = Math.Pow(specBase, shininess) * ks * specStr;

                        double intensity = ka + diffuse + specular;

                        byte r = (byte)(Math.Min(color.X * intensity, 1.0) * 255);
                        byte g = (byte)(Math.Min(color.Y * intensity, 1.0) * 255);
                        byte b = (byte)(Math.Min(color.Z * intensity, 1.0) * 255);

                        int argb = (255 << 24) | (r << 16) | (g << 8) | b;
                        row[x] = argb;

                        _worldPosBuffer[offset + x] = p;
                        _worldNormalBuffer[offset + x] = n;
                        _specularBuffer[offset + x] = (float)specStr;
                        _colorBuffer[offset + x] = argb;
                    }
                }
            }
        }

        public void ApplySSR(Matrix4x4 viewProjMatrix, Matrix4x4 viewportMatrix, Vec4 cameraPos)
        {
            byte* scan0 = _canvas.GetScan0();
            int stride = _canvas.GetStride();

            double maxReflectionDist = 12.0; 
            double thickness = 0.8;          

            for (int y = 0; y < _height; y++)
            {
                int* row = (int*)(scan0 + y * stride);
                int offset = y * _width;

                for (int x = 0; x < _width; x++)
                {
                    int idx = offset + x;
                    if (_zBuffer[idx] == float.MaxValue) continue;

                    float spec = _specularBuffer[idx];
                    if (spec < 0.1f) continue; 

                    Vec4 wPos = _worldPosBuffer[idx];
                    Vec4 wNorm = _worldNormalBuffer[idx];

                    Vec4 viewDir = (cameraPos - wPos).Normalize();
                    Vec4 reflectDir = Vec4.Reflect(viewDir, wNorm).Normalize();

                    Vec4 pStart = wPos + reflectDir * 0.1;
                    Vec4 pEnd = wPos + reflectDir * maxReflectionDist;

                    Vec4 sStartClip = viewProjMatrix * pStart;
                    Vec4 sEndClip = viewProjMatrix * pEnd;

                    if (sStartClip.W < 0.001 || sEndClip.W < 0.001) continue;

                    Vec4 sStart = viewportMatrix * new Vec4(sStartClip.X / sStartClip.W, sStartClip.Y / sStartClip.W, sStartClip.Z / sStartClip.W, 1.0);
                    Vec4 sEnd = viewportMatrix * new Vec4(sEndClip.X / sEndClip.W, sEndClip.Y / sEndClip.W, sEndClip.Z / sEndClip.W, 1.0);

                    Vec4 delta = sEnd - sStart;
                    double maxStepsScreen = Math.Max(Math.Abs(delta.X), Math.Abs(delta.Y));
                    if (maxStepsScreen < 1) continue;

                    delta = delta * (1.0 / maxStepsScreen);
                    int maxSteps = (int)Math.Min(maxStepsScreen, 150);

                    Vec4 current = sStart;
                    bool hit = false;
                    int hitColor = 0;
                    int hitCx = -1, hitCy = -1;
                    double hitDistance3D = 0;

                    for (int i = 1; i <= maxSteps; i++)
                    {
                        current += delta;
                        int cx = (int)current.X;
                        int cy = (int)current.Y;

                        if (cx < 0 || cx >= _width || cy < 0 || cy >= _height) break;

                        float rayZ = (float)current.Z;
                        float currentBufZ = _zBuffer[cy * _width + cx];

                        if (currentBufZ == float.MaxValue) continue;

                        if (rayZ > currentBufZ)
                        {
                            Vec4 gbufPos = _worldPosBuffer[cy * _width + cx];
                            Vec4 toHit = gbufPos - wPos;

                            double rayT = Vec4.Dot(toHit, reflectDir);

                            if (rayT > 0)
                            {
                                Vec4 expectedRayPos = wPos + reflectDir * rayT;

                                double errX = expectedRayPos.X - gbufPos.X;
                                double errY = expectedRayPos.Y - gbufPos.Y;
                                double errZ = expectedRayPos.Z - gbufPos.Z;
                                double error3D = Math.Sqrt(errX * errX + errY * errY + errZ * errZ);

                                if (error3D < thickness)
                                {
                                    hit = true;
                                    hitColor = _colorBuffer[cy * _width + cx];
                                    hitCx = cx;
                                    hitCy = cy;
                                    hitDistance3D = rayT;
                                    break;
                                }
                                
                            }
                        }
                    }

                    if (hit)
                    {
                        double distanceFade = Math.Max(0.0, 1.0 - (hitDistance3D / maxReflectionDist));
                        distanceFade *= distanceFade;

                        double edgeFadeX = Math.Min(1.0, Math.Min(hitCx, _width - hitCx) / (_width * 0.05));
                        double edgeFadeY = Math.Min(1.0, Math.Min(hitCy, _height - hitCy) / (_height * 0.05));
                        double edgeFade = edgeFadeX * edgeFadeY;

                        float refStr = spec * 0.6f * (float)(distanceFade * edgeFade);
                        refStr = Math.Min(refStr, 1.0f);

                        if (refStr > 0.01f)
                        {
                            int baseColor = _colorBuffer[idx];
                            int rBase = (baseColor >> 16) & 255;
                            int gBase = (baseColor >> 8) & 255;
                            int bBase = baseColor & 255;

                            int rHit = (hitColor >> 16) & 255;
                            int gHit = (hitColor >> 8) & 255;
                            int bHit = hitColor & 255;

                            int rF = (int)(rBase * (1 - refStr) + rHit * refStr);
                            int gF = (int)(gBase * (1 - refStr) + gHit * refStr);
                            int bF = (int)(bBase * (1 - refStr) + bHit * refStr);

                            row[x] = (255 << 24) | (rF << 16) | (gF << 8) | bF;
                        }
                    }
                }
            }
        }
        private void Swap<T>(ref T a, ref T b) { T t = a; a = b; b = t; }
    }
}