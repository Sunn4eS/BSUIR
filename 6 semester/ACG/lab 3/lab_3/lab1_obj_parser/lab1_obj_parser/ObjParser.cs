using lab1_obj_parser;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;

namespace lab1_obj_parser
{
    public class Model
    {
        public List<Vec4> Vertices { get; private set; } = new List<Vec4>();
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

                Vec4 edge1 = v2 - v1;
                Vec4 edge2 = v3 - v1;
                Vec4 faceNormal = Vec4.Cross(edge1, edge2);
                
                for (int i = 0; i < face.Length; i++)
                    accumulatedNormals[face[i][0]] += faceNormal;
            }

            Normals.Clear();
            for (int i = 0; i < accumulatedNormals.Length; i++)
                Normals.Add(accumulatedNormals[i].Normalize());

            foreach (var face in Faces)
                for (int i = 0; i < face.Length; i++)
                    face[i][1] = face[i][0];
        }

        private void ParseObj(string path)
        {
            var lines = File.ReadAllLines(path);
            foreach (var line in lines)
            {
                string[] parts = line.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length == 0) continue;

                if (parts[0] == "v")
                {
                    Vertices.Add(new Vec4(
                        double.Parse(parts[1], CultureInfo.InvariantCulture),
                        double.Parse(parts[2], CultureInfo.InvariantCulture),
                        double.Parse(parts[3], CultureInfo.InvariantCulture)
                    ));
                }
                else if (parts[0] == "vn")
                {
                    Normals.Add(new Vec4(
                        double.Parse(parts[1], CultureInfo.InvariantCulture),
                        double.Parse(parts[2], CultureInfo.InvariantCulture),
                        double.Parse(parts[3], CultureInfo.InvariantCulture),
                        0
                    ).Normalize());
                }
                else if (parts[0] == "f")
                {
                    int[][] faceData = new int[parts.Length - 1][];
                    for (int i = 1; i < parts.Length; i++)
                    {
                        string[] subParts = parts[i].Split('/');
                        int vIdx = int.Parse(subParts[0]) - 1;
                        int nIdx = -1;
                        if (subParts.Length > 2 && !string.IsNullOrEmpty(subParts[2]))
                            nIdx = int.Parse(subParts[2]) - 1;

                        faceData[i - 1] = new int[] { vIdx, nIdx };
                    }
                    Faces.Add(faceData);
                }
            }
            if (Normals.Count == 0)
            {
                GenerateNormals();
            }
        }
    }
}