using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;

namespace lab1_obj_parser
{
    public class Model
    {
        public List<Vec4> Vertices { get; private set; } = new List<Vec4>();
        public List<Vec2> UVs { get; private set; } = new List<Vec2>();     // ДОБАВЛЕНО
        public List<Vec4> Normals { get; private set; } = new List<Vec4>();
        public List<int[][]> Faces { get; private set; } = new List<int[][]>();

        public Model(string filepath) { ParseObj(filepath); }

        private void GenerateNormals()
        {
            Vec4[] accumulatedNormals = new Vec4[Vertices.Count];
            foreach (var face in Faces)
            {
                Vec4 v1 = Vertices[face[0][0]];
                Vec4 v2 = Vertices[face[1][0]];
                Vec4 v3 = Vertices[face[2][0]];
                Vec4 faceNormal = Vec4.Cross(v2 - v1, v3 - v1);

                for (int i = 0; i < face.Length; i++) accumulatedNormals[face[i][0]] += faceNormal;
            }
            Normals.Clear();
            for (int i = 0; i < accumulatedNormals.Length; i++) Normals.Add(accumulatedNormals[i].Normalize());
            foreach (var face in Faces) for (int i = 0; i < face.Length; i++) face[i][2] = face[i][0];
        }

        private void ParseObj(string path)
        {
            var lines = File.ReadAllLines(path);
            foreach (var line in lines)
            {
                string[] parts = line.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length == 0) continue;

                if (parts[0] == "v") Vertices.Add(new Vec4(double.Parse(parts[1], CultureInfo.InvariantCulture), double.Parse(parts[2], CultureInfo.InvariantCulture), double.Parse(parts[3], CultureInfo.InvariantCulture)));
                else if (parts[0] == "vt") UVs.Add(new Vec2(double.Parse(parts[1], CultureInfo.InvariantCulture), double.Parse(parts[2], CultureInfo.InvariantCulture))); // ДОБАВЛЕНО
                else if (parts[0] == "vn") Normals.Add(new Vec4(double.Parse(parts[1], CultureInfo.InvariantCulture), double.Parse(parts[2], CultureInfo.InvariantCulture), double.Parse(parts[3], CultureInfo.InvariantCulture), 0).Normalize());
                else if (parts[0] == "f")
                {
                    int[][] faceData = new int[parts.Length - 1][];
                    for (int i = 1; i < parts.Length; i++)
                    {
                        string[] sub = parts[i].Split('/');
                        int vIdx = int.Parse(sub[0]) - 1;
                        int tIdx = (sub.Length > 1 && !string.IsNullOrEmpty(sub[1])) ? int.Parse(sub[1]) - 1 : -1;
                        int nIdx = (sub.Length > 2 && !string.IsNullOrEmpty(sub[2])) ? int.Parse(sub[2]) - 1 : -1;

                        faceData[i - 1] = new int[] { vIdx, tIdx, nIdx }; 
                    }
                    Faces.Add(faceData);
                }
            }
            if (Normals.Count == 0) GenerateNormals();
        }
    }
}