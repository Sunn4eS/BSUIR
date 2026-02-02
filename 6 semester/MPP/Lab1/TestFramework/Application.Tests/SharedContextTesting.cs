using Application.Logic;
using TestFramework;
using System;

namespace Application.Tests
{
    [TestClass(Description = "Полный сценарий работы с БД с использованием всех 10 Asserts")]
    [UseSharedContext(typeof(Database))]
    public class SharedContextTesting
    {
        private readonly UserService _service;
        private readonly Database _db;

        public SharedContextTesting(Database db)
        {
            _db = db;
            _service = new UserService(_db);
        }

        [TestMethod(Priority = 1, Description = "База должна быть пустой при старте")]
        public void Step1_DatabaseStartsEmpty()
        {
            var users = _service.GetAllUsers();
            Assert.IsEmpty(users, "В начале тестов база должна быть пуста");
        }

        [TestMethod(Priority = 2, Description = "Регистрация администратора")]
        public void Step2_RegisterAdmin()
        {
            _service.RegisterUser("Admin", "admin@system.com", 35);

            var admin = _service.GetByEmail("admin@system.com");

            Assert.IsNotNull(admin, "Админ должен быть найден в БД");

            Assert.AreEqual("Admin", admin.Username, "Имя должно совпадать");
            Assert.AreEqual(1, admin.Id, "ID первого пользователя должен быть 1");
        }

        [TestMethod(Priority = 3, Description = "Регистрация второго пользователя и сравнение")]
        public void Step3_RegisterGuest()
        {
            _service.RegisterUser("Guest", "guest@mail.com", 18);

            var admin = _service.GetByEmail("admin@system.com");
            var guest = _service.GetByEmail("guest@mail.com");

            Assert.AreNotEqual(admin, guest, "Админ и Гость — разные объекты");
            Assert.AreNotEqual(admin.Id, guest.Id, "ID должны отличаться");

            var allNames = _service.GetAllUsernames();
            Assert.CollectionContains(allNames, "Guest", "Список имен должен содержать Guest");
        }

        [TestMethod(Priority = 4, Description = "Проверка возраста и статуса")]
        public void Step4_CheckLogic()
        {
            _service.RegisterUser("OldMan", "old@mail.com", 70);
            var pensioner = _service.GetByEmail("old@mail.com");
            var student = _service.GetByEmail("guest@mail.com"); 

            Assert.IsTrue(_service.IsUserPensioner(pensioner), "70 лет должно возвращать True");
            Assert.IsFalse(_service.IsUserPensioner(student), "18 лет должно возвращать False");
        }

        [TestMethod(Priority = 5, Description = "Генерация отчета")]
        public void Step5_CheckReport()
        {
            var report = _service.GetUserReport("admin@system.com");

            Assert.StringContains(report, "Admin", "В отчете должно быть имя");
            Assert.StringContains(report, "[ID:1]", "В отчете должен быть ID");
        }

        [TestMethod(Priority = 6, Description = "Попытка дубликата Email")]
        public void Step6_TryDuplicate_Throws()
        {
            Assert.Throws<InvalidOperationException>(() =>
            {
                _service.RegisterUser("FakeAdmin", "admin@system.com", 20);
            }, "Должна быть ошибка дубликата");
        }

        [TestMethod(Priority = 7, Description = "Удаление пользователя")]
        public void Step7_DeleteUser()
        {
            bool deleted = _service.DeleteUser("guest@mail.com");
            Assert.IsTrue(deleted, "Удаление должно пройти успешно");

            var deletedUser = _service.GetByEmail("guest@mail.com");

            Assert.IsNull(deletedUser, "Удаленный пользователь не должен находиться");
        }
    }
}