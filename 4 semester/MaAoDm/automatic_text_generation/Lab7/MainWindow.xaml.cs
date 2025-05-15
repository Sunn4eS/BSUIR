using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using Syntax;
using Line = Syntax.Line;

namespace Lab7
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private const int WidthDelta = /*137*/10;
        private const int HeightDelta = /*92*/10;
        private const double ResizeDelta = 0.5;

        public MainWindow()
        {
            InitializeComponent();
        }

        private Point _startPoint;

        private bool _isDrawingModeEnabled = false;

        private GeometryGroup _currentGroup;

        private List<Element> _drawnElements = new List<Element>();

        private Grammar _grammar = null;


        private void SynthesisButton_Click(object sender, RoutedEventArgs e)
        {
            var home = _grammar.GetImage();
            Clear();
            foreach (var line in home.Lines)
            {
                _drawnElements.Add(TerminalElementCreator.GetTerminalElement(line));
            }

            home.ScaleTransform((WindowGrid.ActualWidth - WidthDelta) / home.Length * ResizeDelta,
                (WindowGrid.ActualHeight - HeightDelta) / home.Height * ResizeDelta);
            _currentGroup = home.GetGeometryGroup();
            UpdateImage();
        }

        private void Image_MouseUp(object sender, MouseButtonEventArgs e)
        {
            if (_isDrawingModeEnabled)
            {
                _isDrawingModeEnabled = false;
                _drawnElements.Add(TerminalElementCreator.GetTerminalElement(
                    new Line(GetCartesianCoordinates(_startPoint), GetCartesianCoordinates(e.GetPosition(Image)))));
                _currentGroup.Children.Add(new LineGeometry(_startPoint, e.GetPosition(Image)));
                UpdateImage();
            }
            else
            {
                _isDrawingModeEnabled = true;
                _startPoint = e.GetPosition(Image);
            }
        }

        private void UpdateImage()
        {
            Image.Source =
                new DrawingImage(new GeometryDrawing(new SolidColorBrush(Colors.Black),
                    new Pen(new SolidColorBrush(Colors.Black), 2.0), _currentGroup));
        }

        private Point GetCartesianCoordinates(Point position)
        {
            return new Point(position.X, WindowGrid.ActualHeight - 20 - position.Y);
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            ClearImage();
        }

        private void ClearImage()
        {
            _currentGroup = new GeometryGroup();
            _currentGroup.Children.Add(new LineGeometry(new Point(0, 0),
                new Point(0, WindowGrid.ActualHeight - HeightDelta)));
            _currentGroup.Children.Add(new LineGeometry(new Point(0, WindowGrid.ActualHeight - HeightDelta),
                new Point(WindowGrid.ActualWidth - WidthDelta, WindowGrid.ActualHeight - HeightDelta)));
            _currentGroup.Children.Add(
                new LineGeometry(new Point(WindowGrid.ActualWidth - WidthDelta, WindowGrid.ActualHeight - HeightDelta),
                    new Point(WindowGrid.ActualWidth - WidthDelta, 0)));
            _currentGroup.Children.Add(new LineGeometry(new Point(WindowGrid.ActualWidth - WidthDelta, 0),
                new Point(0, 0)));
            UpdateImage();
        }

        private void RecognitionButton_Click(object sender, RoutedEventArgs e)
        {
            var recognizingResult = _grammar.IsImage(_drawnElements);
            MessageBox.Show(recognizingResult.IsHome
                ? "Рисунок соответствует грамматике"
                : $"Рисунок не соответствует грамматике.{Environment.NewLine}Отсутствует: {recognizingResult.ErrorElementName}");
        }

        private void ClearButton_Click(object sender, RoutedEventArgs e)
        {
            Clear();
        }

        private void Clear()
        {
            _currentGroup = new GeometryGroup();
            ClearImage();
            _drawnElements = new List<Element>();
        }

        private void GenerateButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var grammarSyntax = new GrammarSyntax(_drawnElements);
                _grammar = grammarSyntax.Grammar;
                GrammarTextBox.Text = _grammar.ToString();
                SynthesisButton.IsEnabled = true;
                RecognitionButton.IsEnabled = true;
            }
            catch (InvalidElementException)
            {
                MessageBox.Show("Рисунок не распознан");
            }
        }
    }
}