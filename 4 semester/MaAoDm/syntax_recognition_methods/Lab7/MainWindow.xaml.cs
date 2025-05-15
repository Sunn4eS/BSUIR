using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Syntax;
using Line = Syntax.Line;

namespace Lab7
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private Point startPoint;

        private bool isDrawingModeEnabled = false;

        private GeometryGroup currentGroup;

        private List<Element> drawedElements = new List<Element>();

        private void SynthesisButton_Click(object sender, RoutedEventArgs e)
        {
            var grammar = new HomeGrammarOther();
            Element home = grammar.GetHome();
            Clear();
            foreach (Line line in home.Lines)
            {
                drawedElements.Add(HomeGrammar.GetTerminalElement(line));
            }
            home.ScaleTransform((WindowGrid.ActualWidth - 140)/home.Length,
                (WindowGrid.ActualHeight - 25)/home.Height);
            currentGroup =  home.GetGeometryGroup();
            UpdateImage();
        }

        private void Image_MouseUp(object sender, MouseButtonEventArgs e)
        {
            if (isDrawingModeEnabled)
            {
                isDrawingModeEnabled = false;
                drawedElements.Add(HomeGrammar.GetTerminalElement(new Line(GetCortanianCoordinates(startPoint), GetCortanianCoordinates(e.GetPosition(Image)))));
                currentGroup.Children.Add(new LineGeometry(startPoint,  e.GetPosition(Image)));
                UpdateImage();
            }
            else
            {
                isDrawingModeEnabled = true;
                startPoint = e.GetPosition(Image);
            }
        }

        private void UpdateImage()
        {
            Image.Source =
                new DrawingImage(new GeometryDrawing(new SolidColorBrush(Colors.Black),
                    new Pen(new SolidColorBrush(Colors.Black), 1.0), currentGroup));
        }

        private Point GetCortanianCoordinates(Point position)
        {
            return new Point(position.X, WindowGrid.ActualHeight - 20 - position.Y);
        }

        private void ClearImage()
        {
            currentGroup = new GeometryGroup();
            currentGroup.Children.Add(new LineGeometry(new Point(0, 0),
                new Point(0, BorderImage.ActualHeight)));
            currentGroup.Children.Add(new LineGeometry(new Point(0, BorderImage.ActualHeight),
                new Point(BorderImage.ActualWidth, BorderImage.ActualHeight)));
            currentGroup.Children.Add(
                new LineGeometry(new Point(BorderImage.ActualWidth, BorderImage.ActualHeight),
                    new Point(BorderImage.ActualWidth, 0)));
            currentGroup.Children.Add(new LineGeometry(new Point(BorderImage.ActualWidth, 0),
                new Point(0, 0)));
            UpdateImage();
        }

        private void RecognitionButton_Click(object sender, RoutedEventArgs e)
        {
            var grammar = new HomeGrammarOther();
            RecognazingResult recognazingResult = grammar.IsHome(drawedElements);
            if (recognazingResult.IsHome)
            {
                MessageBox.Show("Данный рисунок полностью соответствует граматике");
            }
            else
            {
                MessageBox.Show($"Данный рисунок не соответствует грамматике. {Environment.NewLine}Не найден элемент: {recognazingResult.ErrorElementName}");
            }
        }

        private void ClearButton_Click(object sender, RoutedEventArgs e)
        {
            Clear();
        }

        private void Clear()
        {
            currentGroup = new GeometryGroup();
            ClearImage();
            drawedElements = new List<Element>();
        }
    }
}
