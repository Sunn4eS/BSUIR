using System;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace MIAPR_4;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window
{
    Perceptron _perceptron;

    public MainWindow() => InitializeComponent();

    void ButtonClassify_Click(object sender, RoutedEventArgs e)
    {
        var testObject = new PerceptronObject();
        var regex = new Regex("(^-?[0-9]+$)");
        var index = 1;
        try
        {
            foreach (var item in InputPanel.Children)
            {
                if (item is TextBox textBox)
                {
                    var number = regex.IsMatch(textBox.Text.Trim())
                        ? int.Parse(textBox.Text.Trim())
                        : throw new ArgumentException($"Значение в поле №{index} некорректно");
                    testObject.Attributes.Add(number);
                    index++;
                }
            }

            MessageBox.Show($"Объект относится к {_perceptron.Classify(testObject)} классу");
        }
        catch (ArgumentException exception)
        {
            MessageBox.Show(exception.Message);
        }
        catch
        {
            MessageBox.Show("Ошибка ввода тестовой сборки");
        }
    }

    void ButtonCreateSelection_Click(object sender, RoutedEventArgs e)
    {
        // Используем значения, введенные в текстовые поля
        var attributeNumber = int.Parse(TextBoxAttributeNumber.Text.Trim());
        var classNumber = int.Parse(TextBoxClassesNumber.Text.Trim());
        var objectNumber = int.Parse(TextBoxObjectNumber.Text.Trim());

        // Создаем поля для ввода атрибутов на основе введенного числа
        InputPanel.MakeInputBoxes(attributeNumber, TextCheck);

        ListViewSolutions.ClearListView();
        ListViewSelection.ClearListView();

        _perceptron = new Perceptron(classNumber, objectNumber, attributeNumber);
        _perceptron.Train();

        _perceptron.FillListViews(ListViewSelection, ListViewSolutions);

        void TextCheck(object sender, TextCompositionEventArgs e)
        {
            var regex = new Regex("(^-?[0-9]+$)|(^-?$)");
            if (e.Text == " ") e.Handled = true;
            if (!regex.IsMatch($"{(sender as TextBox)?.Text}{e.Text}")) e.Handled = true;
        }
    }
}
