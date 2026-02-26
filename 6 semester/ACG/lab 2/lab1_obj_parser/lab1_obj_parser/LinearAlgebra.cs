using System;
using System.Runtime.CompilerServices;

namespace lab1_obj_parser
{
    
    public struct Vec4
    {
        public double X, Y, Z, W;

        public Vec4(double x, double y, double z, double w = 1.0)
        {
            X = x; Y = y; Z = z; W = w;
        }

        public static Vec4 operator -(Vec4 a, Vec4 b)
        {
          return new Vec4(a.X - b.X, a.Y - b.Y, a.Z - b.Z, 0); // w=0 для вектора направления
        }
        public static Vec4 Cross(Vec4 a, Vec4 b)
        {
            return new Vec4(
                a.Y * b.Z - a.Z * b.Y,
                a.Z * b.X - a.X * b.Z,
                a.X * b.Y - a.Y * b.X,
                0
            );
        }

        public static double Dot(Vec4 a, Vec4 b) {
            return a.X* b.X + a.Y * b.Y + a.Z * b.Z;
        }
        public Vec4 Normalize()
        {
            double len = Math.Sqrt(X * X + Y * Y + Z * Z);
            if (len == 0) 
                return this;
            else
            {
                this.X /= len;
                this.Y /= len;
                this.Z /= len;
                this.W = 0;
                return this;
            }
                
         
        }
    }

    public class Matrix4x4
    {
        public double[,] M = new double[4, 4];

        public Matrix4x4() { }

        // Единичная матрица
        public static Matrix4x4 Identity()
        {
            Matrix4x4 res = new Matrix4x4();
            for (int i = 0; i < 4; i++) 
                res.M[i, i] = 1;
            return res;
        }

        // Матрица на матрицу
       public static Matrix4x4 operator *(Matrix4x4 a, Matrix4x4 b)
       {
            Matrix4x4 res = new();
            for (int r = 0; r < 4; r++)
            {
                for (int c = 0; c < 4; c++)
                {
                    res.M[r, c] = 0;
                    for (int k = 0; k < 4; k++)
                        res.M[r, c] += a.M[r, k] * b.M[k, c];
                }
            }
            return res;
       }

        // Матрица на вектор
        public static Vec4 operator *(Matrix4x4 m, Vec4 v)
        {
            return new Vec4(
                m.M[0, 0] * v.X + m.M[0, 1] * v.Y + m.M[0, 2] * v.Z + m.M[0, 3] * v.W,
                m.M[1, 0] * v.X + m.M[1, 1] * v.Y + m.M[1, 2] * v.Z + m.M[1, 3] * v.W,
                m.M[2, 0] * v.X + m.M[2, 1] * v.Y + m.M[2, 2] * v.Z + m.M[2, 3] * v.W,
                m.M[3, 0] * v.X + m.M[3, 1] * v.Y + m.M[3, 2] * v.Z + m.M[3, 3] * v.W
            );
        }

        // Матрица перемещения
        public static Matrix4x4 Translation(double tx, double ty, double tz)
        {
            Matrix4x4 res = Identity();
            res.M[0, 3] = tx;
            res.M[1, 3] = ty;
            res.M[2, 3] = tz;
            return res;
        }

        // Матрица масштаба
        public static Matrix4x4 Scale(double sx, double sy, double sz)
        {
            Matrix4x4 res = Identity();
            res.M[0, 0] = sx;
            res.M[1, 1] = sy;
            res.M[2, 2] = sz;
            return res;
        }

        // Матрица поворота вокруг X
        public static Matrix4x4 RotateX(double angleRad)
        {
            Matrix4x4 res = Identity();
            double c = Math.Cos(angleRad);
            double s = Math.Sin(angleRad);
            res.M[1, 1] = c; 
            res.M[1, 2] = -s;
            res.M[2, 1] = s; 
            res.M[2, 2] = c;
            return res;
        }

        // Матрица поворота вокруг Y
        public static Matrix4x4 RotateY(double angleRad)
        {
            Matrix4x4 res = Identity();
            double c = Math.Cos(angleRad);
            double s = Math.Sin(angleRad);
            res.M[0, 0] = c; 
            res.M[0, 2] = s;
            res.M[2, 0] = -s; 
            res.M[2, 2] = c;
            return res;
        }

        // Матрица поворота вокруг Z
        public static Matrix4x4 RotateZ(double angleRad)
        {
            Matrix4x4 res = Identity();
            double c = Math.Cos(angleRad);
            double s = Math.Sin(angleRad);
            res.M[0, 0] = c;
            res.M[0, 1] = -s;
            res.M[1, 0] = s; 
            res.M[1, 1] = c;
            return res;
        }


        public static Matrix4x4 LookAt(Vec4 eye, Vec4 target, Vec4 up)
        {
            Vec4 zAxis = (eye - target).Normalize(); 
            Vec4 xAxis = Vec4.Cross(up, zAxis).Normalize();
            Vec4 yAxis = up;
            
            Matrix4x4 res = Identity();

            res.M[0, 0] = xAxis.X; res.M[0, 1] = xAxis.Y; res.M[0, 2] = xAxis.Z; res.M[0, 3] = -Vec4.Dot(xAxis, eye);
            res.M[1, 0] = yAxis.X; res.M[1, 1] = yAxis.Y; res.M[1, 2] = yAxis.Z; res.M[1, 3] = -Vec4.Dot(yAxis, eye);
            res.M[2, 0] = zAxis.X; res.M[2, 1] = zAxis.Y; res.M[2, 2] = zAxis.Z; res.M[2, 3] = -Vec4.Dot(zAxis, eye);
            
            return res;
        }

       public static Matrix4x4 Perspective(double fov, double aspect, double zNear, double zFar)
        {
            Matrix4x4 res = new(); 
            double tanHalfFov = Math.Tan(fov / 2.0);

            res.M[0, 0] = 1.0 / (aspect * tanHalfFov);
            res.M[1, 1] = 1.0 / tanHalfFov;
            res.M[2, 2] = zFar / (zNear - zFar); 
            res.M[2, 3] = (zNear * zFar) / (zNear - zFar);
            res.M[3, 2] = -1.0; 
            res.M[3, 3] = 0.0;

            return res;
        }

        public static Matrix4x4 Viewport(double width, double height, double xMin = 0, double yMin = 0)
        {
            Matrix4x4 res = Identity();
            res.M[0, 0] = width / 2.0;
            res.M[0, 3] = xMin + width / 2.0;

            res.M[1, 1] = -height / 2.0;
            res.M[1, 3] = yMin + height / 2.0;

            return res;
        }
    }
}