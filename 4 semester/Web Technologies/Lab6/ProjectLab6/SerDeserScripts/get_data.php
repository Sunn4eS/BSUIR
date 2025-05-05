<?php
session_start(); // Продолжение сессии

if (isset($_SESSION['userdata'])) {
    $data = unserialize($_SESSION['userdata']);

    echo "<h3>Десериализованные данные из сессии:</h3>";
    echo "<pre>";
    print_r($data);
    echo "</pre>";
} else {
    echo "Нет данных в сессии. Сначала посетите <a href='set_data.php'>set_data.php</a>.";
}
