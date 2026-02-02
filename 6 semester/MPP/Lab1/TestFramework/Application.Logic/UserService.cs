using Application.Logic;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Application.Logic
{
    public class UserService
    {
        private readonly Database _database;

        // Если базы нет, создаем локальную (для обычных тестов)
        public UserService()
        {
            _database = new Database();
            _database.Init(); // В реальном коде так делать не стоит, но для лабы сойдет
        }

        // Конструктор для внедрения зависимости (для Shared Context тестов)
        public UserService(Database database)
        {
            _database = database;
        }

        public void RegisterUser(string username, string email, int age)
        {
            if (string.IsNullOrWhiteSpace(username))
                throw new ArgumentNullException(nameof(username), "Имя пользователя не может быть пустым");

            if (!email.Contains("@") || !email.Contains("."))
                throw new FormatException("Некорректный формат Email");

            if (age < 18)
                throw new ArgumentException("Пользователь должен быть совершеннолетним", nameof(age));

            if (_database.Users.Any(u => u.Email == email))
                throw new InvalidOperationException("Пользователь с таким Email уже существует");

            var user = new User
            {
                Id = _database.Users.Count + 1,
                Username = username,
                Email = email,
                Age = age
            };

            _database.Users.Add(user);
        }

        public User GetByEmail(string email)
        {
            return _database.Users.FirstOrDefault(u => u.Email == email);
        }

        // Асинхронный метод: отправка приветственного письма
        public async Task<bool> SendWelcomeEmailAsync(string email)
        {
            var user = GetByEmail(email);
            if (user == null) return false;

            // Имитация отправки по сети
            await Task.Delay(300);
            return true;
        }
        
        // 1. Возвращает всех пользователей (для CollectionContains)
        public List<User> GetAllUsers()
        {
            return _database.Users;
        }

        // 2. Возвращает список имен (для CollectionContains<string>)
        public List<string> GetAllUsernames()
        {
            return _database.Users.Select(u => u.Username).ToList();
        }

        // 3. Удаляет пользователя (для проверки уменьшения списка)
        public bool DeleteUser(string email)
        {
            var user = GetByEmail(email);
            if (user == null) return false;
            return _database.Users.Remove(user);
        }

        // 4. Проверка возраста (для IsTrue/IsFalse)
        public bool IsUserPensioner(User user)
        {
            if (user == null) throw new ArgumentNullException(nameof(user));
            return user.Age >= 65;
        }

        // 5. Метод генерации отчета (для StringContains)
        public string GetUserReport(string email)
        {
            var user = GetByEmail(email);
            if (user == null) return "User not found";
            return $"REPORT: User {user.Username} [ID:{user.Id}] is registered.";
        }
    }
}