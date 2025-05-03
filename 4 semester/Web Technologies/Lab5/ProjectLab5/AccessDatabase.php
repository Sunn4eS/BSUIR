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
$sql = "
    SELECT Users.id, user_name, last_order, MusicalInstruments.type AS instrument_type, MusicalInstruments.price
    FROM Users
    JOIN MusicalInstruments ON Users.type_of_order_id = MusicalInstruments.id
    ORDER BY user_name ASC;
";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
    echo "<h2>Список пользователей и заказанных инструментов</h2>";
    echo "<table border='1' cellpadding='8' cellspacing='0'>";
    echo "<tr><th>ID</th><th>Имя пользователя</th><th>Дата заказа</th><th>Тип инструмента</th><th>Цена</th></tr>";

    while ($row = $result->fetch_assoc()) {
        echo "<tr>";
        echo "<td>" . htmlspecialchars($row['id']) . "</td>";
        echo "<td>" . htmlspecialchars($row['user_name']) . "</td>";
        echo "<td>" . htmlspecialchars($row['last_order']) . "</td>";
        echo "<td>" . htmlspecialchars($row['instrument_type']) . "</td>";
        echo "<td>" . htmlspecialchars($row['price']) . " BYN</td>";
        echo "</tr>";
    }

    echo "</table>";
} else {
    echo "Нет данных для отображения.";
}
$conn->close();