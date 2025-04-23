<?php

class MySQLConnector
{
    private mysqli $connection;

    public function __construct(string $host, string $user, string $password, string $database = "")
    {
        $this->connection = new mysqli($host, $user, $password, $database);

        if ($this->connection->connect_error) {
            die("Ошибка подключения: " . $this->connection->connect_error);
        }
    }

    public function getServerVersion(): string
    {
        return $this->connection->server_info;
    }

    public function close(): void
    {
        $this->connection->close();
    }
}

$host = "localhost";
$user = "sasha";
$password = "08062023"; // или твой пароль
$database = ""; // можешь указать базу данных, если нужно

$mysql = new MySQLConnector($host, $user, $password, $database);
echo "Версия MySQL: " . $mysql->getServerVersion();
$mysql->close();
