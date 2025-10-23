using System;
using System.Windows.Forms;

namespace MSiSvIT
{
    internal static class Program
    {
        /// <summary>
        /// Главная точка входа для приложения.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // Настройка стилей отображения приложения
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Запуск главной формы
            Application.Run(new MainForm());
        }
    }
}