using System;

namespace BankClientsApp
{
    public class Client
    {
        public int Id { get; set; }
        public string LastName { get; set; }
        public string FirstName { get; set; }
        public string Patronymic { get; set; }
        public DateTime BirthDate { get; set; }
        public string PassportSeries { get; set; }
        public string PassportNumber { get; set; }
        public string IssuedBy { get; set; }
        public DateTime IssueDate { get; set; }
        public string IdNumber { get; set; }
        public string BirthPlace { get; set; }

        public int ActualCityId { get; set; }
        public string ActualCityName { get; set; }
        public string ActualAddress { get; set; }

        public string HomePhone { get; set; }
        public string MobilePhone { get; set; }
        public string Email { get; set; }
        public string Workplace { get; set; }
        public string Position { get; set; }

        public int MaritalStatusId { get; set; }
        public string MaritalStatusName { get; set; }

        public int CitizenshipId { get; set; }
        public string CitizenshipName { get; set; }

        public int DisabilityId { get; set; }
        public string DisabilityName { get; set; }

        public bool IsPensioner { get; set; }
        public decimal? MonthlyIncome { get; set; }
        public bool IsLiableForMilitaryService { get; set; }
    }

    public class LookupItem
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public override string ToString() => Name;
    }
}