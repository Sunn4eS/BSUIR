<?php
const DB_HOST = 'localhost';
const DB_USER = 'sasha';
const DB_PASS = '08062023';
const DB_NAME = 'MusicShop';

$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
if (!$conn) {
    die("Connection failed: " . $conn->connect_error);
}
$conn->set_charset("utf8");

// Получаем все таблицы
$result = $conn->query("SHOW TABLES");
$tables = [];
while ($row = $result->fetch_array()) {
    $tables[] = $row[0];
}

// HTML-шапка
echo "<!DOCTYPE html><html lang='ru'><head><meta charset='UTF-8'><title>Структура БД</title>";
echo "<style>
        body { font-family: sans-serif; padding: 20px; }
        h2 { color: #333; }
        table { border-collapse: collapse; margin-bottom: 40px; width: 100%; }
        th, td { border: 1px solid #aaa; padding: 8px; text-align: left; }
        th { background: #eee; }
      </style></head><body>";
echo "<h1>Структура и данные базы данных: <code>" . DB_NAME . "</code></h1>";

foreach ($tables as $table) {
    echo "<h2>Таблица: <code>$table</code></h2>";

    // Структура таблицы
    echo "<h3>Структура</h3>";
    echo "<table><tr><th>Поле</th><th>Тип</th><th>Ключ</th><th>Дополнительно</th></tr>";
    $desc = $conn->query("SHOW FULL COLUMNS FROM `$table`");
    while ($col = $desc->fetch_assoc()) {
        echo "<tr>
            <td>{$col['Field']}</td>
            <td>{$col['Type']}</td>
            <td>{$col['Key']}</td>
            <td>{$col['Extra']}</td>
        </tr>";
    }
    echo "</table>";

    // Данные таблицы
    echo "<h3>Данные</h3>";
    $data = $conn->query("SELECT * FROM `$table`");
    if ($data->num_rows > 0) {
        echo "<table><tr>";
        while ($field = $data->fetch_field()) {
            echo "<th>{$field->name}</th>";
        }
        echo "</tr>";

        while ($row = $data->fetch_assoc()) {
            echo "<tr>";
            foreach ($row as $val) {
                echo "<td>" . htmlspecialchars($val) . "</td>";
            }
            echo "</tr>";
        }
        echo "</table>";
    } else {
        echo "<p><i>Нет данных</i></p>";
    }
}

echo "</body></html>";

$conn->close();
?>
