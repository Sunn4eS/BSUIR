using Application.Logic;
using TestFramework;
using System;

namespace Application.Tests
{
    [TestClass(Description = "Модульные тесты валидации пользователя", RunParallel = true)]
    public class ValidationTests
    {
        private UserService _service;

        [Setup]
        public void Setup()
        {
            _service = new UserService();
        }

        [TestMethod]
        public void Test_User1()
        {
            _service.RegisterUser("User1", "u1@mail.com", 20);
        }

        [TestMethod]
        public void Test_User2()
        {
            _service.RegisterUser("User2", "u2@mail.com", 22);
        }

        [TestMethod]
        public void Test_User3()
        {
            _service.RegisterUser("User3", "u3@mail.com", 23);
        }

        [TestMethod]
        public void Test_User4()
        {
            _service.RegisterUser("User4", "u4@mail.com", 24);
        }

        [TestMethod(Skip = true, Description = "Успешная регистрация")]
        public void Test_Register_ValidUser_Success()
        {
            _service.RegisterUser("Ivan", "ivan@test.com", 25);
            var user = _service.GetByEmail("ivan@test.com");

            Assert.IsNotNull(user);
            Assert.AreEqual("Ivan", user.Username);
        }

        [TestMethod(Skip = false, Description = "Ошибка при регистрации ребенка")]
        public void Test_Register_Underage_ThrowsException()
        {
            Assert.Throws<ArgumentException>(() =>
            {
                _service.RegisterUser("Kid", "kid@test.com", 18);
            });
        }

        [TestMethod(Description = "Ошибка при неверном Email")]
        [TestCase("bademail")]
        [TestCase("email@nodot")]
        [TestCase("noat.com")]
        public void Test_Register_InvalidEmail(string badEmail)
        {
            Assert.Throws<FormatException>(() =>
            {
                _service.RegisterUser("User", badEmail, 20);
            });
        }

        [TestMethod]
        [Timeout(500)]
        public void Test_ShouldFailByTimeout()
        {
            _service.SlowOperation();
        }
    }
}