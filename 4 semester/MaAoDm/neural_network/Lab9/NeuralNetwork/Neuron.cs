using System;
using System.Collections.Generic;
using System.Linq;

namespace NeuralNetwork
{
    [Serializable]
    internal class Neuron
    {
        private readonly int vectorSize;
        private readonly List<int> weight;

        public Neuron(int vectorSize)
        {
            this.vectorSize = vectorSize;
            weight = GetRandomWeight(vectorSize);
        }

        private static List<int> GetRandomWeight(int vectorSize)
        {
            var random = new Random();
            var weight = new List<int>();
            for (var i = 0; i < vectorSize; i++)
            {
                weight.Add(random.Next(10));
            }
            return weight;
        }

        public int GetAnswer(IEnumerable<int> element)
        {
            return element.Select((x, i) => x*weight[i]).Sum();
        }

        public void Teaching(List<int> element, int factor)
        {
            for (var i = 0; i < vectorSize; i++)
            {
                weight[i] += factor*element[i];
            }
        }
    }
}