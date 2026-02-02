using System;
using System.Threading.Tasks;


namespace Application.Logic
{
    public class User
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public int Age { get; set; }

        public override string ToString() => $"{Username} ({Email})";
    }
}