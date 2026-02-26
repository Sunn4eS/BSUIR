using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Application.Logic
{
    public class UserService
    {
        private readonly Database _database;

        public UserService()
        {
            _database = new Database();
            _database.Init();
        }

        public UserService(Database database)
        {
            _database = database;
        }

        public void RegisterUser(string username, string email, int age)
        {
            Thread.Sleep(1000);
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

            _database.AddUserSafe(user);
        }

        public void SlowOperation()
        {
            Thread.Sleep(2000); 
        }

        public User GetByEmail(string email)
        {
            return _database.Users.FirstOrDefault(u => u.Email == email);
        }

        public async Task<bool> SendWelcomeEmailAsync(string email)
        {
            var user = GetByEmail(email);
            if (user == null) return false;

            await Task.Delay(300);
            return true;
        }
        
        // 1. Возвращает всех пользователей
        public List<User> GetAllUsers()
        {
            return _database.Users;
        }

        // 2. Возвращает список имен 
        public List<string> GetAllUsernames()
        {
            return _database.Users.Select(u => u.Username).ToList();
        }

        // 3. Удаляет пользователя 
        public bool DeleteUser(string email)
        {
            var user = GetByEmail(email);
            if (user == null) return false;
            return _database.Users.Remove(user);
        }

        // 4. Проверка возраста 
        public bool IsUserPensioner(User user)
        {
            if (user == null) throw new ArgumentNullException(nameof(user));
            return user.Age >= 65;
        }

        // 5. Метод генерации отчета 
        public string GetUserReport(string email)
        {
            var user = GetByEmail(email);
            if (user == null) return "User not found";
            return $"REPORT: User {user.Username} [ID:{user.Id}] is registered.";
        }
    }
}