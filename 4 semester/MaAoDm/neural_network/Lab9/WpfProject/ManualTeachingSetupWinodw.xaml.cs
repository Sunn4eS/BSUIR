using System.Collections.Generic;
using System.Windows;

namespace WpfProject
{
    /// <summary>
    ///     Interaction logic for ManualTeachingSetupWinodw.xaml
    /// </summary>
    public partial class ManualTeachingSetupWinodw : Window
    {
        public ManualTeachingSetupWinodw()
        {
            InitializeComponent();
            Names = new List<NameDataGridRow>();
            SetNamesGridSize();
        }

        public List<NameDataGridRow> Names { get; set; }
        public int NeuronsCount { get; set; }

        private void ElementsCountUpDown_ValueChanged(object sender,
            RoutedPropertyChangedEventArgs<object> e)
        {
            NeuronsCount = ElementsCountUpDown.Value ?? 0;
            if (NamesDataGrid != null)
            {
                SetNamesGridSize();
            }
        }

        private void SetNamesGridSize()
        {
            Names = new List<NameDataGridRow>();
            for (var i = 0; i < ElementsCountUpDown.Value; i++)
            {
                Names.Add(new NameDataGridRow(i.ToString()));
            }
            NamesDataGrid.ItemsSource = Names;
            NamesDataGrid.ColumnWidth = Width - 50;
        }

        private void OKButton_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = true;
        }
    }
}