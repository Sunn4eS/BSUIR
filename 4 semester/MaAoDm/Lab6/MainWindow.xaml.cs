using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using Lab6.models;
using OxyPlot;

namespace Lab6;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window, INotifyPropertyChanged
{
    private bool _isMaxMode;
    private const int MaxDistance = 10;
    private PlotModel _plotModel;

    public PlotModel PlotModel
    {
        get => _plotModel;
        set
        {
            _plotModel = value;
            OnPropertyChanged(nameof(PlotModel)); // Уведомляем UI об изменении
        }
    }
    
    
    public MainWindow()
    {
        _isMaxMode = false;
        InitializeComponent();
        PlotModel = new PlotModel { Title = "Иерархическое Группирование" };
        DataContext = this;
    }

    private void OnCheckBoxMaxMode(object sender, RoutedEventArgs e)
    {
        _isMaxMode = CheckBoxMaxMode.IsChecked ?? false;
    }
    
    private void BuildClusters(object sender, RoutedEventArgs e)
    {
        int count = Convert.ToInt32(CountInput.Text);
        
        // генерируем расстояния
        double[,] distances = GenerateDistances(count);
        /*double[,] distances = {
            { 0, 5, 0.5, 2 },
            { 5, 0, 1, 0.6 },
            { 0.5, 1, 0, 2.5 },
            { 2, 0.6, 2.5, 0 }
        };*/
        
        // если метод максимума, то разворачиваем расстояния
        if (_isMaxMode)
        {
            ToMaxMode(distances);
        }
        
        // отображаем расстояния
        DisplayDistances(distances);
        
        // Запускаем метод
        HierarchicalMethod hMethod = new HierarchicalMethod(distances);
        OxyGroup finalOxyGroup = hMethod.Compute();
        
        // Отображаем итоговый график
        PlotModel = new OxyPlotDrawer().Draw(finalOxyGroup);
    }
    
    private double[,] GenerateDistances(int count)
    {
        double[,] distances = new double[count,count];
        Random random = new Random();
        
        // генерируем треугольником
        for (int i = 1; i < count; i++)
        {
            for (int j = 0; j < i; j++)
            {
                distances[i, j] = distances[j,i] = Math.Round(random.NextDouble() * MaxDistance, 2);
            }
        }
        
        return distances;
    }

    private void ToMaxMode(double[,] distances)
    {
        int count = distances.GetLength(0);
        for (int i = 1; i < count; i++)
        {
            for (int j = 0; j < i; j++)
            {
                distances[i, j] = distances[j, i] = Math.Round(1 / distances[j, i], 2);
            }
        }
    }
    
    private void DisplayDistances(double[,] distances)
    {
        DistanceTable.ItemsSource = null;
        DistanceTable.Columns.Clear();
        int count = distances.GetLength(0);

        // Список для хранения данных
        var table = new List<List<string>>();

        // Заполнение таблицы данными
        for (int i = 0; i < count; i++)
        {
            var row = new List<string>();
            for (int j = 0; j < count; j++)
            {
                row.Add(distances[i,j].ToString());
            }
            table.Add(row);
        }
        
        // Настройка столбцов DataGrid
        for (int j = 0; j < count; j++)
        {
            var column = new DataGridTextColumn
            {
                Header = $"x{j + 1}",
                Binding = new System.Windows.Data.Binding($"[{j}]"),
                IsReadOnly = true
            };
            DistanceTable.Columns.Add(column);
        }
        
        // Привязка данных к DataGrid
        DistanceTable.ItemsSource = table;

        // Назначаем заголовки строк для каждой строки
        DistanceTable.LoadingRow += (_, e) =>
        {
            e.Row.Header = $"x{e.Row.GetIndex() + 1}";
        };
    }


    public event PropertyChangedEventHandler PropertyChanged;
    
    protected void OnPropertyChanged(string propertyName) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
}