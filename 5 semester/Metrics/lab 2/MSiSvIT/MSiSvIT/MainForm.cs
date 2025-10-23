using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace MSiSvIT
{
    public partial class MainForm : Form
    {
        private readonly RubyCodeAnalyzer _analyzer;
        private Dictionary<string, int> _currentOperators;
      //  private Dictionary<string, int> _currentOperands;
        // Меняем HalsteadMetrics на CodeMetrics
        private CodeMetrics _currentMetrics;

        public MainForm()
        {
            InitializeComponent();
            _analyzer = new RubyCodeAnalyzer();
            _currentOperators = new Dictionary<string, int>();
          //  _currentOperands = new Dictionary<string, int>();
            // Инициализируем CodeMetrics
            _currentMetrics = new CodeMetrics();

            // Подписываемся на события кнопок
            loadButton.Click += LoadButton_Click;
            calculateButton.Click += CalculateButton_Click;

            // Настраиваем открытие файлов для Ruby
            openFileDialog.Filter = "Ruby файлы|*.rb|Текстовые файлы|*.txt|Все файлы|*.*";
            openFileDialog.Title = "Выберите файл с Ruby кодом";

            // Добавляем обработчики двойного клика по таблицам
            operatorsDataGridView.CellDoubleClick += OperatorsDataGridView_CellDoubleClick;
        //    operandsDataGridView.CellDoubleClick += OperandsDataGridView_CellDoubleClick;
        }

        private void LoadButton_Click(object sender, EventArgs e)
        {
            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    string code = File.ReadAllText(openFileDialog.FileName);
                    codeTextBox.Text = code;

                    // Очищаем предыдущие результаты
                    ClearResults();
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Ошибка загрузки файла: {ex.Message}", "Ошибка",
                        MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void CalculateButton_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(codeTextBox.Text))
            {
                MessageBox.Show("Загрузите код Ruby для анализа", "Информация",
                    MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            try
            {
                // Тип возвращаемого значения теперь CodeMetrics
                _currentMetrics = _analyzer.CalculateMetrics(codeTextBox.Text);

                // Сохраняем текущие операторы и операнды
                _currentOperators = _analyzer.GetLastOperators();
              //  _currentOperands = _analyzer.GetLastOperands();

                // Обновляем таблицы
                UpdateOperatorsTable();
            //    UpdateOperandsTable();

                // Обновляем метрики - Теперь показываем метрики Джилба и уровень вложенности
                // clLabel (бывший vocabularyLabel)
                clLabel.Text = _currentMetrics.AbsoluteComplexity.ToString();

                // relativeComplexityLabel (бывший programLengthLabel)
                relativeComplexityLabel.Text = _currentMetrics.RelativeComplexity.ToString("F4");

                // maxNestingLevelLabel (бывший volumeLabel)
                maxNestingLevelLabel.Text = _currentMetrics.MaxNestingLevel.ToString();

                // Обновляем информацию о счетчиках
                UpdateCountersInfo();

                // Обновляем tooltip для новых метрик
                ShowControlFlowMetricsTooltip(_currentMetrics);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка анализа кода: {ex.Message}", "Ошибка",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void UpdateOperatorsTable()
        {
            operatorsDataGridView.Rows.Clear();

            foreach (var op in _currentOperators.OrderByDescending(x => x.Value))
            {
                operatorsDataGridView.Rows.Add(op.Key, op.Value);
            }

            // Обновляем заголовок с информацией об операторах
            operatorsDataGridView.Columns[0].HeaderText = $"Операторы (уник: {_currentOperators.Count}, всего: {_currentMetrics.TotalOperatorsCount})";
        }

        //private void UpdateOperandsTable()
        //{
        //    operandsDataGridView.Rows.Clear();

        //    foreach (var op in _currentOperands.OrderByDescending(x => x.Value))
        //    {
        //        operandsDataGridView.Rows.Add(op.Key, op.Value);
        //    }

        //    // Обновляем заголовок с информацией об операндах
        //    operandsDataGridView.Columns[0].HeaderText = $"Операнды (уник: {_currentOperands.Count}, всего: {_currentMetrics.TotalOperandsCount})";
        //}

        // Обновляем UpdateCountersInfo для отображения Длины (N)
        private void UpdateCountersInfo()
        {
            toolTip.SetToolTip(relativeComplexityLabel,
                $"Всего операторов (N1): {_currentMetrics.TotalOperatorsCount}\n" +
                $"Всего операндов (N2): {_currentMetrics.TotalOperandsCount}\n" +
                $"Общая длина программы (N): {_currentMetrics.Length} = N1 + N2");
        }

        // Удаляем ShowAdditionalMetricsTooltip и заменяем на ShowControlFlowMetricsTooltip
        private void ShowControlFlowMetricsTooltip(CodeMetrics metrics)
        {
            string tooltipText = $"Метрики сложности потока управления:\n\n" +
                $"Абсолютная сложность по Джилбу (CL): {metrics.AbsoluteComplexity}\n" +
                $"Относительная сложность по Джилбу (c): {metrics.RelativeComplexity:F4}\n" +
                $"Максимальный уровень вложенности (MaxNL): {metrics.MaxNestingLevel}\n\n" +
                $"Расчет относительной сложности: c = CL / N, где N - длина программы\n" +
                $"N (длина программы): {metrics.Length} = {metrics.TotalOperatorsCount} (N1) + {metrics.TotalOperandsCount} (N2)";

            toolTip.SetToolTip(clLabel, tooltipText);
            toolTip.SetToolTip(relativeComplexityLabel, tooltipText);
            toolTip.SetToolTip(maxNestingLevelLabel, tooltipText);
        }

        private void ClearResults()
        {
            operatorsDataGridView.Rows.Clear();
            //operandsDataGridView.Rows.Clear();

            // Обновляем Label'ы
            clLabel.Text = "0"; // Был vocabularyLabel
            relativeComplexityLabel.Text = "0"; // Был programLengthLabel
            maxNestingLevelLabel.Text = "0"; // Был volumeLabel

            _currentOperators.Clear();
        //    _currentOperands.Clear();
            // Инициализируем CodeMetrics
            _currentMetrics = new CodeMetrics();

            // Восстанавливаем стандартные заголовки
            operatorsDataGridView.Columns[0].HeaderText = "Оператор";
       //     operandsDataGridView.Columns[0].HeaderText = "Операнд";
        }

        private void OperatorsDataGridView_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            // Метод сохранен без изменений
        }

        //private void OperandsDataGridView_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        //{
        //    // Метод сохранен без изменений
        //}

        // Обновляем SaveResultsToFile
        private void SaveResultsToFile()
        {
            using (var saveFileDialog = new SaveFileDialog())
            {
                saveFileDialog.Filter = "Текстовый файл|*.txt|Все файлы|*.*";
                saveFileDialog.Title = "Сохранить результаты анализа";
                saveFileDialog.FileName = $"Ruby_Analysis_{DateTime.Now:yyyyMMdd_HHmmss}.txt";

                if (saveFileDialog.ShowDialog() == DialogResult.OK)
                {
                    try
                    {
                        using (var writer = new StreamWriter(saveFileDialog.FileName))
                        {
                            writer.WriteLine($"--- Результаты анализа кода Ruby ---\n");

                            // Метрики Джилба и вложенность
                            writer.WriteLine($"МЕТРИКИ ДЖИЛБА И ВЛОЖЕННОСТЬ:");
                            writer.WriteLine($"Абсолютная сложность (CL): {_currentMetrics.AbsoluteComplexity}");
                            writer.WriteLine($"Относительная сложность (c): {_currentMetrics.RelativeComplexity:F4}");
                            writer.WriteLine($"Максимальный уровень вложенности (MaxNL): {_currentMetrics.MaxNestingLevel}");

                            writer.WriteLine();
                            writer.WriteLine($"СЧЕТЧИКИ:");
                            writer.WriteLine($"Уникальные операторы (η1): {_currentMetrics.UniqueOperatorsCount}");
                      //      writer.WriteLine($"Уникальные операнды (η2): {_currentMetrics.UniqueOperandsCount}");
                            writer.WriteLine($"Всего операторов (N1): {_currentMetrics.TotalOperatorsCount}");
                        //    writer.WriteLine($"Всего операндов (N2): {_currentMetrics.TotalOperandsCount}");
                            writer.WriteLine($"Длина программы (N): {_currentMetrics.Length}\n");

                            // Таблицы операторов и операндов
                            writer.WriteLine($"ОПЕРАТОРЫ (уник: {_currentMetrics.UniqueOperatorsCount}, всего: {_currentMetrics.TotalOperatorsCount}):");
                            foreach (var op in _currentOperators.OrderByDescending(x => x.Value))
                            {
                                writer.WriteLine($"{op.Key}: {op.Value}");
                            }

                            //writer.WriteLine();
                            //writer.WriteLine($"ОПЕРАНДЫ (уник: {_currentMetrics.UniqueOperandsCount}, всего: {_currentMetrics.TotalOperandsCount}):");
                            //foreach (var op in _currentOperands.OrderByDescending(x => x.Value))
                            //{
                            //    writer.WriteLine($"{op.Key}: {op.Value}");
                            //}
                        }

                        MessageBox.Show("Результаты успешно сохранены", "Успех",
                            MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Ошибка сохранения: {ex.Message}", "Ошибка",
                            MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            // Добавляем контекстное меню
            var contextMenu = new ContextMenuStrip();
            var saveMenuItem = new ToolStripMenuItem("Сохранить результаты");
            saveMenuItem.Click += (s, args) => SaveResultsToFile();
            contextMenu.Items.Add(saveMenuItem);

            operatorsDataGridView.ContextMenuStrip = contextMenu;
          //  operandsDataGridView.ContextMenuStrip = contextMenu;
        }
    }
}