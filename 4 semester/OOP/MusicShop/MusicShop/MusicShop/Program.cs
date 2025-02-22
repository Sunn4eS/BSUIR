using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;


namespace MusicShop
{
    
    
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        
            
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            
            var elixirStrings = new Strings("9123EJ", "Elixir", 60, 11, 53, "bronze");
            var acousticGuitar1 = new AcousticGuitar("acoustic", "Fender", "30c", 6, 800, "Dreadnout", "USA", elixirStrings);
            var acousticPanel = new Panel();
            acousticPanel.Controls.Add(acousticGuitar1.Print());
            Form1 mainForm = new Form1();
            mainForm.Controls.Add(acousticPanel);
            Application.Run(mainForm);
        }
    }
}