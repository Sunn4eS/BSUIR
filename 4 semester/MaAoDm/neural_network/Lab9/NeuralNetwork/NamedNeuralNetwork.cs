using System;
using System.Collections.Generic;

namespace NeuralNetwork
{
    [Serializable]
    public class NamedNeuralNetwork
    {
        private readonly NeuralNetwork neuralNetwork;
        private readonly List<string> neuronsNames;

        public NamedNeuralNetwork(int vectorSize, List<String> neuronsNames)
        {
            this.neuronsNames = neuronsNames;
            neuralNetwork = new NeuralNetwork(vectorSize, neuronsNames.Count);
        }

        public void Teaching(List<int> element, String correctClassName)
        {
            var correctClass = neuronsNames.FindIndex(x => x == correctClassName);
            if (correctClass == -1) throw new ArgumentException("Invalid class name");
            neuralNetwork.Teaching(element, correctClass);
        }

        public String GetAnswer(List<int> element)
        {
            return neuronsNames[neuralNetwork.GetAnswer(element)];
        }
    }
}