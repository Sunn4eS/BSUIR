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
        public List<int[]> Faces { get; private set; } = new List<int[]>();

        public Model(string filepath)
        {
            ParseObj(filepath);
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
                    double x = double.Parse(parts[1], CultureInfo.InvariantCulture);
                    double y = double.Parse(parts[2], CultureInfo.InvariantCulture);
                    double z = double.Parse(parts[3], CultureInfo.InvariantCulture);
                    
                    double w = parts.Length > 4 ? double.Parse(parts[4], CultureInfo.InvariantCulture) : 1.0;
                    Vertices.Add(new Vec4(x, y, z, w));
                }
                else if (parts[0] == "f") 
                {
                    int[] indices = new int[parts.Length - 1];
                    for (int i = 1; i < parts.Length; i++)
                    {
                        string[] formatParts = parts[i].Split('/');
                        int index = int.Parse(formatParts[0]);

                        // Обработка отрицательных индексов (ссылка с конца списка)
                        if (index < 0) 
                            index = Vertices.Count + index;
                        else 
                            index = index - 1; 

                        indices[i - 1] = index;
                    }
                    Faces.Add(indices);
                }
            }
        }
    }
}