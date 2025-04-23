<?php
class SQLTableRenderer {
    private mysqli $connection;

    public function __construct(string $host, string $user, string $password, string $database) {
        $this->connection = new mysqli($host, $user, $password, $database);

        if ($this->connection->connect_error) {
            die("Ошибка подключения: " . $this->connection->connect_error);
        }
    }

    public function renderSelectAsTable(string $query): string {
        $result = $this->connection->query($query);

        if (!$result) {
            return "Ошибка выполнения запроса: " . $this->connection->error;
        }

        if ($result->num_rows === 0) {
            return "Нет данных для отображения.";
        }

        $html = "<table border='1' cellpadding='5' cellspacing='0'><tr>";

        // Заголовки таблицы
        while ($field = $result->fetch_field()) {
            $html .= "<th>" . htmlspecialchars($field->name) . "</th>";
        }
        $html .= "</tr>";

        // Данные
        while ($row = $result->fetch_assoc()) {
            $html .= "<tr>";
            foreach ($row as $value) {
                $html .= "<td>" . htmlspecialchars($value) . "</td>";
            }
            $html .= "</tr>";
        }

        $html .= "</table>";
        return $html;
    }

    public function close(): void {
        $this->connection->close();
    }
}

$host = "localhost";
$user = "sasha";
$password = "08062023"; // твой пароль
$database = "MusicStore";
$query = "SELECT * FROM Categories"; // любой SELECT-запрос

$renderer = new SQLTableRenderer($host, $user, $password, $database);
echo $renderer->renderSelectAsTable($query);
$renderer->close();
