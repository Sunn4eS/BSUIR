using System;
using System.Text.RegularExpressions;

namespace BankClientsApp
{
    public static class ClientValidator
    {
        public static void Validate(Client client)
        {
            if (string.IsNullOrWhiteSpace(client.LastName))
                throw new ArgumentException("Фамилия обязательна для заполнения!");
            if (string.IsNullOrWhiteSpace(client.FirstName))
                throw new ArgumentException("Имя обязательно для заполнения!");
            if (string.IsNullOrWhiteSpace(client.Patronymic))
                throw new ArgumentException("Отчество обязательно для заполнения!");
            if (string.IsNullOrWhiteSpace(client.PassportSeries))
                throw new ArgumentException("Серия паспорта обязательна!");
            if (string.IsNullOrWhiteSpace(client.PassportNumber))
                throw new ArgumentException("Номер паспорта обязателен!");
            if (string.IsNullOrWhiteSpace(client.IssuedBy))
                throw new ArgumentException("Поле 'Кем выдан' обязательно!");
            if (string.IsNullOrWhiteSpace(client.IdNumber))
                throw new ArgumentException("Идентификационный номер обязателен!");
            if (string.IsNullOrWhiteSpace(client.BirthPlace))
                throw new ArgumentException("Место рождения обязательно!");
            if (string.IsNullOrWhiteSpace(client.ActualAddress))
                throw new ArgumentException("Адрес фактического проживания обязателен!");

            Regex nameRegex = new Regex(@"^[А-Яа-яЁёA-Za-z\s-]+$");
            if (!nameRegex.IsMatch(client.LastName.Trim()))
                throw new ArgumentException("Фамилия содержит недопустимые символы или цифры!");
            if (!nameRegex.IsMatch(client.FirstName.Trim()))
                throw new ArgumentException("Имя содержит недопустимые символы или цифры!");
            if (!nameRegex.IsMatch(client.Patronymic.Trim()))
                throw new ArgumentException("Отчество содержит недопустимые символы или цифры!");

            if (client.BirthDate > DateTime.Now)
                throw new ArgumentException("Дата рождения не может быть в будущем!");
            if (client.IssueDate > DateTime.Now)
                throw new ArgumentException("Дата выдачи паспорта не может быть в будущем!");
            if (client.IssueDate < client.BirthDate)
                throw new ArgumentException("Дата выдачи паспорта не может быть раньше даты рождения!");

            Regex idRegex = new Regex(@"^\d{7}[A-Z]\d{3}[A-Z]{2}\d$");
            if (!idRegex.IsMatch(client.IdNumber.Trim()))
                throw new ArgumentException("Идентификационный номер не соответствует формату (пример: 3010190A001PB1)!");

            if (!string.IsNullOrWhiteSpace(client.Email))
            {
                Regex emailRegex = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                if (!emailRegex.IsMatch(client.Email.Trim()))
                    throw new ArgumentException("Некорректный формат E-mail!");
            }

            if (client.MonthlyIncome.HasValue && client.MonthlyIncome < 0)
                throw new ArgumentException("Ежемесячный доход не может быть отрицательным!");
        }
    }
}