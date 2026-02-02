using Application.Logic;
using TestFramework; // Ссылка на наш фреймворк
using System;
using System.Collections.Generic;
using System.Threading;

namespace Application.Logic
{
    // Имитация подключения к БД. Это "тяжелый" ресурс.
    // Реализует ISharedContext, чтобы раннер знал, как его инициализировать.
    public class Database : ISharedContext
    {
        public List<User> Users { get; private set; }
        public bool IsConnected { get; private set; }

        public void Init()
        {
            Console.WriteLine("  [DB] Подключение к базе данных...");
            // Имитируем задержку соединения
            Thread.Sleep(800);
            Users = new List<User>();
            IsConnected = true;
            Console.WriteLine("  [DB] Соединение установлено.");
        }

        public void Cleanup()
        {
            Console.WriteLine("  [DB] Очистка базы данных и закрытие соединения.");
            Users.Clear();
            IsConnected = false;
        }
    }
}