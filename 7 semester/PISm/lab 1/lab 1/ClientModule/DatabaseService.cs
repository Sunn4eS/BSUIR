using System;
using System.Collections.Generic;
using Npgsql;

namespace BankClientsApp
{
    public class DatabaseService
    {
        private readonly string _connectionString;

        public DatabaseService(string connectionString)
        {
            _connectionString = connectionString;
        }

        public List<Client> GetClientsSortedByLastName()
        {
            var clients = new List<Client>();
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                string sql = @"
                    SELECT c.*, ci.name AS city_name, ms.status_name, cs.country_name, ds.group_name
                    FROM clients c
                    JOIN cities ci ON c.actual_city_id = ci.id
                    JOIN marital_statuses ms ON c.marital_status_id = ms.id
                    JOIN citizenships cs ON c.citizenship_id = cs.id
                    JOIN disability_statuses ds ON c.disability_id = ds.id
                    ORDER BY c.last_name, c.first_name, c.patronymic;";

                using (var cmd = new NpgsqlCommand(sql, conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        clients.Add(new Client
                        {
                            Id = reader.GetInt32(reader.GetOrdinal("id")),
                            LastName = reader.GetString(reader.GetOrdinal("last_name")),
                            FirstName = reader.GetString(reader.GetOrdinal("first_name")),
                            Patronymic = reader.GetString(reader.GetOrdinal("patronymic")),
                            BirthDate = reader.GetDateTime(reader.GetOrdinal("birth_date")),
                            PassportSeries = reader.GetString(reader.GetOrdinal("passport_series")),
                            PassportNumber = reader.GetString(reader.GetOrdinal("passport_number")),
                            IssuedBy = reader.GetString(reader.GetOrdinal("issued_by")),
                            IssueDate = reader.GetDateTime(reader.GetOrdinal("issue_date")),
                            IdNumber = reader.GetString(reader.GetOrdinal("id_number")),
                            BirthPlace = reader.GetString(reader.GetOrdinal("birth_place")),
                            ActualCityId = reader.GetInt32(reader.GetOrdinal("actual_city_id")),
                            ActualCityName = reader.GetString(reader.GetOrdinal("city_name")),
                            ActualAddress = reader.GetString(reader.GetOrdinal("actual_address")),
                            HomePhone = reader.IsDBNull(reader.GetOrdinal("home_phone")) ? null : reader.GetString(reader.GetOrdinal("home_phone")),
                            MobilePhone = reader.IsDBNull(reader.GetOrdinal("mobile_phone")) ? null : reader.GetString(reader.GetOrdinal("mobile_phone")),
                            Email = reader.IsDBNull(reader.GetOrdinal("email")) ? null : reader.GetString(reader.GetOrdinal("email")),
                            Workplace = reader.IsDBNull(reader.GetOrdinal("workplace")) ? null : reader.GetString(reader.GetOrdinal("workplace")),
                            Position = reader.IsDBNull(reader.GetOrdinal("position")) ? null : reader.GetString(reader.GetOrdinal("position")),
                            MaritalStatusId = reader.GetInt32(reader.GetOrdinal("marital_status_id")),
                            MaritalStatusName = reader.GetString(reader.GetOrdinal("status_name")),
                            CitizenshipId = reader.GetInt32(reader.GetOrdinal("citizenship_id")),
                            CitizenshipName = reader.GetString(reader.GetOrdinal("country_name")),
                            DisabilityId = reader.GetInt32(reader.GetOrdinal("disability_id")),
                            DisabilityName = reader.GetString(reader.GetOrdinal("group_name")),
                            IsPensioner = reader.GetBoolean(reader.GetOrdinal("is_pensioner")),
                            MonthlyIncome = reader.IsDBNull(reader.GetOrdinal("monthly_income")) ? (decimal?)null : reader.GetDecimal(reader.GetOrdinal("monthly_income")),
                            IsLiableForMilitaryService = reader.GetBoolean(reader.GetOrdinal("is_liable_for_military_service"))
                        });
                    }
                }
            }
            return clients;
        }

        public void AddClient(Client client)
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                string sql = @"
                    INSERT INTO clients (
                        last_name, first_name, patronymic, birth_date, passport_series, passport_number,
                        issued_by, issue_date, id_number, birth_place, actual_city_id, actual_address,
                        home_phone, mobile_phone, email, workplace, position, marital_status_id,
                        citizenship_id, disability_id, is_pensioner, monthly_income, is_liable_for_military_service
                    ) VALUES (
                        @last_name, @first_name, @patronymic, @birth_date, @passport_series, @passport_number,
                        @issued_by, @issue_date, @id_number, @birth_place, @actual_city_id, @actual_address,
                        @home_phone, @mobile_phone, @email, @workplace, @position, @marital_status_id,
                        @citizenship_id, @disability_id, @is_pensioner, @monthly_income, @is_liable_for_military_service
                    );";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    AddParameters(cmd, client);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void DeleteClient(int id)
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand("DELETE FROM clients WHERE id = @id;", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public List<LookupItem> GetLookupData(string tableName, string nameColumn)
        {
            var list = new List<LookupItem>();
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand($"SELECT id, {nameColumn} FROM {tableName} ORDER BY id;", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new LookupItem { Id = reader.GetInt32(0), Name = reader.GetString(1) });
                    }
                }
            }
            return list;

        }
        public void UpdateClient(Client client)
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                string sql = @"
            UPDATE clients SET 
                last_name=@last_name, first_name=@first_name, patronymic=@patronymic, birth_date=@birth_date,
                passport_series=@passport_series, passport_number=@passport_number, issued_by=@issued_by,
                issue_date=@issue_date, id_number=@id_number, birth_place=@birth_place, actual_city_id=@actual_city_id,
                actual_address=@actual_address, home_phone=@home_phone, mobile_phone=@mobile_phone, email=@email,
                workplace=@workplace, position=@position, marital_status_id=@marital_status_id,
                citizenship_id=@citizenship_id, disability_id=@disability_id, is_pensioner=@is_pensioner,
                monthly_income=@monthly_income, is_liable_for_military_service=@is_liable_for_military_service
            WHERE id = @id;";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", client.Id);
                    AddParameters(cmd, client);
                    cmd.ExecuteNonQuery();
                }
            }
        }


        private void AddParameters(NpgsqlCommand cmd, Client c)
        {
            cmd.Parameters.AddWithValue("@last_name", c.LastName);
            cmd.Parameters.AddWithValue("@first_name", c.FirstName);
            cmd.Parameters.AddWithValue("@patronymic", c.Patronymic);
            cmd.Parameters.AddWithValue("@birth_date", c.BirthDate);
            cmd.Parameters.AddWithValue("@passport_series", c.PassportSeries);
            cmd.Parameters.AddWithValue("@passport_number", c.PassportNumber);
            cmd.Parameters.AddWithValue("@issued_by", c.IssuedBy);
            cmd.Parameters.AddWithValue("@issue_date", c.IssueDate);
            cmd.Parameters.AddWithValue("@id_number", c.IdNumber);
            cmd.Parameters.AddWithValue("@birth_place", c.BirthPlace);
            cmd.Parameters.AddWithValue("@actual_city_id", c.ActualCityId);
            cmd.Parameters.AddWithValue("@actual_address", c.ActualAddress);
            cmd.Parameters.AddWithValue("@home_phone", (object)c.HomePhone ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@mobile_phone", (object)c.MobilePhone ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@email", (object)c.Email ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@workplace", (object)c.Workplace ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@position", (object)c.Position ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@marital_status_id", c.MaritalStatusId);
            cmd.Parameters.AddWithValue("@citizenship_id", c.CitizenshipId);
            cmd.Parameters.AddWithValue("@disability_id", c.DisabilityId);
            cmd.Parameters.AddWithValue("@is_pensioner", c.IsPensioner);
            cmd.Parameters.AddWithValue("@monthly_income", (object)c.MonthlyIncome ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@is_liable_for_military_service", c.IsLiableForMilitaryService);
        }
    }
}