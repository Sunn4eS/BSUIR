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
        private Dictionary<string, int> _currentOperands;
        private HalsteadMetrics _currentMetrics;

        public MainForm()
        {
            InitializeComponent();
            _analyzer = new RubyCodeAnalyzer();
            _currentOperators = new Dictionary<string, int>();
            _currentOperands = new Dictionary<string, int>();
            _currentMetrics = new HalsteadMetrics();

            // Подписываемся на события кнопок
            loadButton.Click += LoadButton_Click;
            calculateButton.Click += CalculateButton_Click;

            // Настраиваем открытие файлов для Ruby
            openFileDialog.Filter = "Ruby файлы|*.rb|Текстовые файлы|*.txt|Все файлы|*.*";
            openFileDialog.Title = "Выберите файл с Ruby кодом";

            // Добавляем обработчики двойного клика по таблицам
            operatorsDataGridView.CellDoubleClick += OperatorsDataGridView_CellDoubleClick;
            operandsDataGridView.CellDoubleClick += OperandsDataGridView_CellDoubleClick;
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
                _currentMetrics = _analyzer.CalculateMetrics(codeTextBox.Text);

                // Сохраняем текущие операторы и операнды
                _currentOperators = _analyzer.GetLastOperators();
                _currentOperands = _analyzer.GetLastOperands();

                // Обновляем таблицы
                UpdateOperatorsTable();
                UpdateOperandsTable();

                // Обновляем метрики - теперь показываем правильные значения
                vocabularyLabel.Text = _currentMetrics.Vocabulary.ToString();
                programLengthLabel.Text = _currentMetrics.Length.ToString(); // Теперь это общая длина
                volumeLabel.Text = _currentMetrics.Volume.ToString("F2");

                // Добавляем информацию о количестве операторов и операндов
                UpdateCountersInfo();

                // Показываем дополнительные метрики в tooltip
                ShowAdditionalMetricsTooltip(_currentMetrics);
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

        private void UpdateOperandsTable()
        {
            operandsDataGridView.Rows.Clear();

            foreach (var op in _currentOperands.OrderByDescending(x => x.Value))
            {
                operandsDataGridView.Rows.Add(op.Key, op.Value);
            }

            // Обновляем заголовок с информацией об операндах
            operandsDataGridView.Columns[0].HeaderText = $"Операнды (уник: {_currentOperands.Count}, всего: {_currentMetrics.TotalOperandsCount})";
        }

        private void UpdateCountersInfo()
        {
            // Добавляем информацию о количестве операторов и операндов
            toolTip.SetToolTip(programLengthLabel,
                $"Всего операторов: {_currentMetrics.TotalOperatorsCount}\n" +
                $"Всего операндов: {_currentMetrics.TotalOperandsCount}\n" +
                $"Длина программы (N): {_currentMetrics.Length} = {_currentMetrics.TotalOperatorsCount} + {_currentMetrics.TotalOperandsCount}");
        }

        private void ClearResults()
        {
            operatorsDataGridView.Rows.Clear();
            operandsDataGridView.Rows.Clear();
            vocabularyLabel.Text = "0";
            programLengthLabel.Text = "0";
            volumeLabel.Text = "0";
            _currentOperators.Clear();
            _currentOperands.Clear();
            _currentMetrics = new HalsteadMetrics();

            // Восстанавливаем стандартные заголовки
            operatorsDataGridView.Columns[0].HeaderText = "Оператор";
            operandsDataGridView.Columns[0].HeaderText = "Операнд";
        }

        private void ShowAdditionalMetricsTooltip(HalsteadMetrics metrics)
        {
            string tooltipText = $"Дополнительные метрики Халстеда:\n\n" +
                               $"Уникальные операторы (η1): {metrics.UniqueOperatorsCount}\n" +
                               $"Уникальные операнды (η2): {metrics.UniqueOperandsCount}\n" +
                               $"Всего операторов (N1): {metrics.TotalOperatorsCount}\n" +
                               $"Всего операндов (N2): {metrics.TotalOperandsCount}\n" +
                               $"Словарь (η): {metrics.Vocabulary} = η1 + η2\n" +
                               $"Длина программы (N): {metrics.Length} = N1 + N2\n" +
                               $"Объём (V): {metrics.Volume:F2} = N × log₂(η)\n" +
                               $"Сложность (D): {metrics.Difficulty:F2}\n" +
                               $"Усилия (E): {metrics.Effort:F2} = D × V\n" +
                               $"Время реализации (T): {metrics.Time:F2} сек\n" +
                               $"Ошибки (B): {metrics.Bugs:F4}";

            toolTip.SetToolTip(volumeLabel, tooltipText);
            toolTip.SetToolTip(programLengthLabel, tooltipText);
            toolTip.SetToolTip(vocabularyLabel, tooltipText);
        }

        // Остальные методы остаются без изменений...
        private void OperatorsDataGridView_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0 && e.ColumnIndex == 0)
            {
                string operatorName = operatorsDataGridView.Rows[e.RowIndex].Cells[0].Value.ToString();
                HighlightTextInCode(operatorName);
            }
        }

        private void OperandsDataGridView_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0 && e.ColumnIndex == 0)
            {
                string operandName = operandsDataGridView.Rows[e.RowIndex].Cells[0].Value.ToString();
                HighlightTextInCode(operandName);
            }
        }

        private void HighlightTextInCode(string text)
        {
            if (string.IsNullOrEmpty(text)) return;

            int index = codeTextBox.Text.IndexOf(text, StringComparison.Ordinal);
            if (index >= 0)
            {
                codeTextBox.Select(index, text.Length);
                codeTextBox.ScrollToCaret();
                codeTextBox.Focus();
            }
        }

        private void SaveResultsToFile()
        {
            using (var saveDialog = new SaveFileDialog())
            {
                saveDialog.Filter = "Текстовые файлы|*.txt|CSV файлы|*.csv";
                saveDialog.Title = "Сохранить результаты анализа";

                if (saveDialog.ShowDialog() == DialogResult.OK)
                {
                    try
                    {
                        using (var writer = new StreamWriter(saveDialog.FileName))
                        {
                            writer.WriteLine("Результаты анализа метрик Халстеда");
                            writer.WriteLine("===================================");
                            writer.WriteLine();

                            writer.WriteLine($"Уникальные операторы (η1): {_currentMetrics.UniqueOperatorsCount}");
                            writer.WriteLine($"Уникальные операнды (η2): {_currentMetrics.UniqueOperandsCount}");
                            writer.WriteLine($"Всего операторов (N1): {_currentMetrics.TotalOperatorsCount}");
                            writer.WriteLine($"Всего операндов (N2): {_currentMetrics.TotalOperandsCount}");
                            writer.WriteLine($"Словарь программы (η): {_currentMetrics.Vocabulary}");
                            writer.WriteLine($"Длина программы (N): {_currentMetrics.Length}");
                            writer.WriteLine($"Объём программы (V): {_currentMetrics.Volume:F2}");
                            writer.WriteLine($"Сложность (D): {_currentMetrics.Difficulty:F2}");
                            writer.WriteLine($"Усилия (E): {_currentMetrics.Effort:F2}");
                            writer.WriteLine($"Время реализации (T): {_currentMetrics.Time:F2} сек");
                            writer.WriteLine($"Ошибки (B): {_currentMetrics.Bugs:F4}");
                            writer.WriteLine();

                            writer.WriteLine("ОПЕРАТОРЫ:");
                            foreach (var op in _currentOperators.OrderByDescending(x => x.Value))
                            {
                                writer.WriteLine($"{op.Key}: {op.Value}");
                            }

                            writer.WriteLine();
                            writer.WriteLine("ОПЕРАНДЫ:");
                            foreach (var op in _currentOperands.OrderByDescending(x => x.Value))
                            {
                                writer.WriteLine($"{op.Key}: {op.Value}");
                            }
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
            operandsDataGridView.ContextMenuStrip = contextMenu;
        }
    }
}