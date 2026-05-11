using System;
using System.Runtime.CompilerServices;

namespace lab1_obj_parser
{
    public struct Vec2
    {
        public double X, Y;

        public Vec2(double x, double y) { X = x; Y = y; }

        public static Vec2 operator -(Vec2 a, Vec2 b) => new Vec2(a.X - b.X, a.Y - b.Y);
        public static Vec2 operator +(Vec2 a, Vec2 b) => new Vec2(a.X + b.X, a.Y + b.Y);
        public static Vec2 operator *(Vec2 a, double b) => new Vec2(a.X * b, a.Y * b);
    }

    public struct Vec4
    {
        public double X, Y, Z, W;

        public Vec4(double x, double y, double z, double w = 1.0)
        {
            X = x; Y = y; Z = z; W = w;
        }

        public static Vec4 operator -(Vec4 a, Vec4 b) => new Vec4(a.X - b.X, a.Y - b.Y, a.Z - b.Z, a.W - b.W);
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static Vec4 operator +(Vec4 a, Vec4 b) => new Vec4(a.X + b.X, a.Y + b.Y, a.Z + b.Z, a.W + b.W);
        public static Vec4 operator *(Vec4 a, double b) => new Vec4(a.X * b, a.Y * b, a.Z * b, a.W * b);

        public static Vec4 Reflect(Vec4 L, Vec4 N)
        {
            double dot = Dot(L, N);
            return N * (2.0 * dot) - L;
        }

        public static Vec4 Cross(Vec4 a, Vec4 b) => new Vec4(
            a.Y * b.Z - a.Z * b.Y,
            a.Z * b.X - a.X * b.Z,
            a.X * b.Y - a.Y * b.X, 0);

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static double Dot(Vec4 a, Vec4 b) => a.X * b.X + a.Y * b.Y + a.Z * b.Z;

        public Vec4 Normalize()
        {
            double len = Math.Sqrt(X * X + Y * Y + Z * Z);
            if (len > 0) { X /= len; Y /= len; Z /= len; }
            return this;
        }
    }

    public class Matrix4x4
    {
        public double[,] M = new double[4, 4];
        public Matrix4x4() { }

        public static Matrix4x4 Identity()
        {
            Matrix4x4 res = new Matrix4x4();
            for (int i = 0; i < 4; i++) res.M[i, i] = 1;
            return res;
        }

        public static Matrix4x4 operator *(Matrix4x4 a, Matrix4x4 b)
        {
            Matrix4x4 res = new();
            for (int r = 0; r < 4; r++)
                for (int c = 0; c < 4; c++)
                    for (int k = 0; k < 4; k++)
                        res.M[r, c] += a.M[r, k] * b.M[k, c];
            return res;
        }

        public static Vec4 operator *(Matrix4x4 m, Vec4 v) => new Vec4(
            m.M[0, 0] * v.X + m.M[0, 1] * v.Y + m.M[0, 2] * v.Z + m.M[0, 3] * v.W,
            m.M[1, 0] * v.X + m.M[1, 1] * v.Y + m.M[1, 2] * v.Z + m.M[1, 3] * v.W,
            m.M[2, 0] * v.X + m.M[2, 1] * v.Y + m.M[2, 2] * v.Z + m.M[2, 3] * v.W,
            m.M[3, 0] * v.X + m.M[3, 1] * v.Y + m.M[3, 2] * v.Z + m.M[3, 3] * v.W
        );

        public static Matrix4x4 Translation(double tx, double ty, double tz) { var r = Identity(); r.M[0, 3] = tx; r.M[1, 3] = ty; r.M[2, 3] = tz; return r; }
        public static Matrix4x4 Scale(double sx, double sy, double sz) { var r = Identity(); r.M[0, 0] = sx; r.M[1, 1] = sy; r.M[2, 2] = sz; return r; }
        public static Matrix4x4 RotateX(double a) { var r = Identity(); double c = Math.Cos(a), s = Math.Sin(a); r.M[1, 1] = c; r.M[1, 2] = -s; r.M[2, 1] = s; r.M[2, 2] = c; return r; }
        public static Matrix4x4 RotateY(double a) { var r = Identity(); double c = Math.Cos(a), s = Math.Sin(a); r.M[0, 0] = c; r.M[0, 2] = s; r.M[2, 0] = -s; r.M[2, 2] = c; return r; }
        public static Matrix4x4 RotateZ(double a) { var r = Identity(); double c = Math.Cos(a), s = Math.Sin(a); r.M[0, 0] = c; r.M[0, 1] = -s; r.M[1, 0] = s; r.M[1, 1] = c; return r; }

        public static Matrix4x4 LookAt(Vec4 eye, Vec4 target, Vec4 up)
        {
            Vec4 z = (eye - target).Normalize();
            Vec4 x = Vec4.Cross(up, z).Normalize();
            Vec4 y = up;
            Matrix4x4 r = Identity();
            r.M[0, 0] = x.X; r.M[0, 1] = x.Y; r.M[0, 2] = x.Z; r.M[0, 3] = -Vec4.Dot(x, eye);
            r.M[1, 0] = y.X; r.M[1, 1] = y.Y; r.M[1, 2] = y.Z; r.M[1, 3] = -Vec4.Dot(y, eye);
            r.M[2, 0] = z.X; r.M[2, 1] = z.Y; r.M[2, 2] = z.Z; r.M[2, 3] = -Vec4.Dot(z, eye);
            return r;
        }

        public static Matrix4x4 Perspective(double fov, double aspect, double zNear, double zFar)
        {
            Matrix4x4 r = new();
            double tanHalfFov = Math.Tan(fov / 2.0);
            r.M[0, 0] = 1.0 / (aspect * tanHalfFov);
            r.M[1, 1] = 1.0 / tanHalfFov;
            r.M[2, 2] = zFar / (zNear - zFar);
            r.M[2, 3] = (zNear * zFar) / (zNear - zFar);
            r.M[3, 2] = -1.0;
            return r;
        }

        public static Matrix4x4 Viewport(double w, double h, double x = 0, double y = 0)
        {
            var r = Identity();
            r.M[0, 0] = w / 2.0; r.M[0, 3] = x + w / 2.0;
            r.M[1, 1] = -h / 2.0; r.M[1, 3] = y + h / 2.0;
            return r;
        }
    }
}