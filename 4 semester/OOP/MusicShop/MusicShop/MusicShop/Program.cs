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
        private const int SHIFT = 150;
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        
            
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Form1 mainForm = new Form1();
            
            var guitarStrings = new Strings("11052", "Elixir", 93, 12, 53, "bronze");
            var acousticGuitar = new AcousticGuitar("acoustic", "Fender", "30c", 6, 800, "Dreadnout", "USA", guitarStrings);
            var guitarBelt = new Belt("Dunlop", "D07-01RD", "Lether", 32);
            var guitarPick = new GuitarPick("Alice", "Pick", 1, "Black", 96);
            var electricGuitar = new ElectricGuitar("Electric", "H-H", "Tune-o_matic", "Gibson", "Tribute", 6, 2916,
                "Les-Paul", "USA", guitarStrings);
            
            var acousticPanel = Utility.Print("images\\Fender_30с.jpg", SHIFT * 0, 0, acousticGuitar);
            var stringsPanel = Utility.Print("images\\Elixir_11052.jpg", SHIFT * 1, 0, guitarStrings);
            var beltPanel = Utility.Print("images\\Dunlop_D07-01RD.jpg", SHIFT * 2, 0, guitarBelt);
            var guitarPickPanel = Utility.Print("images\\Alice_GuitarPick96.jpg", SHIFT * 3, 0, guitarPick);
            var electricGuitarPanel = Utility.Print("images\\Gibson_Tribute.jpg", SHIFT * 4, 0, electricGuitar);
            
            mainForm.Controls.Add(electricGuitarPanel);
            mainForm.Controls.Add(guitarPickPanel);
            mainForm.Controls.Add(beltPanel);
            mainForm.Controls.Add(acousticPanel);
            mainForm.Controls.Add(stringsPanel);
            
            
            Application.Run(mainForm);
        }
    }
}