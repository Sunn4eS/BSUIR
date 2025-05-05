<?php
session_start(); // Запуск сессии

// Генерация произвольных данных
$data = [
    'number' => rand(1, 100),
    'string' => bin2hex(random_bytes(5)),
    'array' => ['cat', 'dog', 'fish'],
    'assoc' => ['username' => 'guest', 'theme' => 'dark']
];

// Сохраняем сериализованные данные в сессию
$_SESSION['userdata'] = serialize($data);

// Устанавливаем куку для идентификации пользователя
setcookie('user_id', session_id(), time() + 3600); // 1 час

echo "Данные сохранены в сессию и cookie установлена.<br>";
echo "<a href='get_data.php'>Перейти к просмотру данных</a>";
