using TestFramework; 
using System;
using System.Collections.Generic;
using System.Threading;

namespace Application.Logic
{
    public class Database : ISharedContext
    {
        private readonly object _syncLock = new object();

        public List<User> Users { get; private set; }
        public bool IsConnected { get; private set; }

        public void Init()
        {
            Console.WriteLine("  [DB] Подключение к базе данных...");
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

        public void AddUserSafe(User user)
        {
            // Lock гарантирует, что только один поток зайдет сюда в единицу времени
            lock (_syncLock)
            {
                user.Id = Users.Count + 1;
                Users.Add(user);
            }
        }

        public List<User> GetAllSafe()
        {
            lock (_syncLock)
            {
                // Возвращаем копию, чтобы никто не менял оригинал во время перебора
                return new List<User>(Users);
            }
        }
    }
}