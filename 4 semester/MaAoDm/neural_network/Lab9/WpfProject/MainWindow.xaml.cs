using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using System.Windows;
using System.Windows.Forms;
using ImageLoad;
using NeuralNetwork;
using MessageBox = System.Windows.MessageBox;
using OpenFileDialog = Microsoft.Win32.OpenFileDialog;
using SaveFileDialog = Microsoft.Win32.SaveFileDialog;

namespace WpfProject
{
    /// <summary>
    ///     Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private const int imageSize = 30;
        private const int autoTeachingIterationsCount = 9;
        private Bitmap bitmap;
        private NamedNeuralNetwork network;

        public MainWindow()
        {
            InitializeComponent();
        }

        private void ManualTeaching_Click(object sender, RoutedEventArgs e)
        {
            var setup = new ManualTeachingSetupWinodw();
            if (setup.ShowDialog() ?? false)
            {
                network = new NamedNeuralNetwork(imageSize * imageSize,
                    setup.Names.Select(x => x.Name).ToList());
            }

            LoadImageButton.IsEnabled = true;
        }

        private void StartWork()
        {
            TeachingButton.IsEnabled = true;
            TeachingClassTextBox.IsEnabled = true;
            ClassificationButton.IsEnabled = true;
            SaveNetworkButton.IsEnabled = true;
        }

        private void LoadImageButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter =
                    "Images (*.bmp, *.png, *.jpg, *.jpeg)|*.bmp;*.png;*.jpg;*.jpeg|All files|*.*"
            };
            if (!(openFileDialog.ShowDialog() ?? false)) return;
            bitmap = BitmapConverter.Load(openFileDialog.FileName, imageSize);
            CurrentImage.Source = BitmapConverter.ToBitmapImage(bitmap);
            StartWork();
        }

        private void TeachingButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                network.Teaching(BitmapConverter.ToInt32List(bitmap), TeachingClassTextBox.Text);
            }
            catch (ArgumentException)
            {
                MessageBox.Show("Неверное имя класса", "МиАПР 9", MessageBoxButton.OK,
                    MessageBoxImage.Error);
            }
        }

        private void ClassificationButton_Click(object sender, RoutedEventArgs e)
        {
            ClassificationResultLabel.Text = network.GetAnswer(BitmapConverter.ToInt32List(bitmap));
        }

        private void SaveNetworkButton_Click(object sender, RoutedEventArgs e)
        {
            var saveFileDialog = new SaveFileDialog
            {
                Filter = "Saved neural network (*.snn)|*.snn"
            };
            if (!(saveFileDialog.ShowDialog() ?? false)) return;
            using (var fileStream = new FileStream(saveFileDialog.FileName, FileMode.Create))
            {
                var serializer = new BinaryFormatter();
                serializer.Serialize(fileStream, network);
            }
        }

        private void OpenReadyNetwork_Click(object sender, RoutedEventArgs e)
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = "Saved neural network (*.snn)|*.snn"
            };
            if (openFileDialog.ShowDialog() ?? false)
            {
                using (var fileStream = new FileStream(openFileDialog.FileName, FileMode.Open))
                {
                    var serializer = new BinaryFormatter();
                    network = (NamedNeuralNetwork) serializer.Deserialize(fileStream);
                }
            }

            LoadImageButton.IsEnabled = true;
        }

        private void AutoTeaching_Click(object sender, RoutedEventArgs e)
        {
            var folderBrowserDialog = new FolderBrowserDialog();
            if (folderBrowserDialog.ShowDialog() != System.Windows.Forms.DialogResult.OK) return;
            var directory = new DirectoryInfo(folderBrowserDialog.SelectedPath);
            var neuronsNames = GetNeuronsNames(directory);
            network = new NamedNeuralNetwork(imageSize * imageSize, neuronsNames);
            while (!AutoEducationEnd(directory))
            {
                TeachFromDirectory(directory);
            }

            LoadImageButton.IsEnabled = true;
            SaveNetworkButton.IsEnabled = true;
        }

        private void TeachFromDirectory(DirectoryInfo directory)
        {
            foreach (var file in directory.GetFiles("*.png"))
            {
                var neuronName = file.Name.Split('-')[0];
                network.Teaching(GetElementFromPath(directory, file),
                    neuronName);
            }
        }

        private bool AutoEducationEnd(DirectoryInfo directory)
        {
            return !(from file in directory.GetFiles("*.png")
                let neuronName = file.Name.Split('-')[0]
                where network.GetAnswer(GetElementFromPath(directory, file)) != neuronName
                select file).Any();
        }

        private static List<int> GetElementFromPath(DirectoryInfo directory, FileInfo file)
        {
            return BitmapConverter.ToInt32List(
                BitmapConverter.Load(
                    $"{directory}\\{file.Name}", imageSize));
        }

        private static List<string> GetNeuronsNames(DirectoryInfo directory)
        {
            var neuronsNames = new List<string>();
            foreach (var file in directory.GetFiles())
            {
                var neuronNames = file.Name.Split('-')[0];
                if (!neuronsNames.Contains(neuronNames))
                {
                    neuronsNames.Add(neuronNames);
                }
            }

            return neuronsNames;
        }
    }
}