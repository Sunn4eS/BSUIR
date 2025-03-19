using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MusicShop
{
    public partial class Form1 : Form
    {
        private const int SHIFT = 150;
        public AddForm.MusicShopManager _manager = new AddForm.MusicShopManager();
        public Form1()
        {
            // Инициализация FlowLayoutPanel
            //itemsflowLayoutPanel.AutoScroll = true;
            //itemsflowLayoutPanel.FlowDirection = FlowDirection.TopDown;
            //itemsflowLayoutPanel.WrapContents = false;
            InitializeComponent();
        }
        private void UpdateItemsPanel()
        {
            itemsflowLayoutPanel.Controls.Clear();
            int i = 0;
            foreach (var item in _manager.GetItems())
            {
                if (item is IProductInfo product)
                {
                    var panel = Utility.Print(i * 1, 0,product);
                    itemsflowLayoutPanel.Controls.Add(panel);
                }
                i++;
            }
        }
        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void addButton_Click(object sender, EventArgs e)
        {
            contextMenuStrip.Show(addButton, new Point(0, addButton.Height));
        }

        private void acousticToolStripMenuItem_Click(object sender, EventArgs e)
        {
                _manager.ShowInputForm("Acoustic Guitar");    
        }
    }
}