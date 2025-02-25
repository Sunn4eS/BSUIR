using System;
using System.Collections.Generic;
using System.Drawing;
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
            Form1 mainForm = new Form1();
            
            var elixirStrings = new Strings("11052", "Elixir", 93, 12, 53, "bronze");
            var acousticFender = new AcousticGuitar("acoustic", "Fender", "30c", 6, 800, "Dreadnout", "USA", elixirStrings);
            var beltDunlop = new Belt("Dunlop", "D07-01RD", "Lether", 32);
            
            var acousticPanel = Utility.Print("images\\Fender_30с.jpg", 0, 0, acousticFender);
            var stringsPanel = Utility.Print("images\\Elixir_11052.jpg", 150, 0, elixirStrings);
            var beltPanel = Utility.Print("images\\Dunlop_D07-01RD.jpg", 300, 0, beltDunlop);
            
            mainForm.Controls.Add(beltPanel);
            mainForm.Controls.Add(acousticPanel);
            mainForm.Controls.Add(stringsPanel);
            
            
            Application.Run(mainForm);
        }
    }
}