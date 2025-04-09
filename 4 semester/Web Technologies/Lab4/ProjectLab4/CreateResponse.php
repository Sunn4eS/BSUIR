<?php
$dataFile = 'reviews.txt';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name'] ?? '');
    $message = trim($_POST['message'] ?? '');

    if (!empty($name) && !empty($message)) {
        $processedMessage = preg_replace('/https?:\/\/(?!([a-z0-9-]+\.)?bsuir\.by)\S+/i', '#Внешние ссылки запрещены#', $message);
        // Сохранение отзыва
        $review = [
            'name' => htmlspecialchars($name, ENT_QUOTES, 'UTF-8'),
            'message' => htmlspecialchars($processedMessage, ENT_QUOTES, 'UTF-8'),
            'date' => date('Y-m-d H:i:s')
        ];

        file_put_contents($dataFile, json_encode($review) . PHP_EOL, FILE_APPEND);
    }
}
$reviews = [];
if (file_exists($dataFile)) {
    $lines = file($dataFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        $reviews[] = json_decode($line, true);
    }
    $reviews = array_reverse($reviews);
}
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Система отзывов</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .review { border: 1px solid #ddd; padding: 15px; margin-bottom: 15px; border-radius: 5px; }
        .review h3 { margin-top: 0; }
        .review .date { color: #666; font-size: 0.9em; }
        form { margin-top: 30px; }
        textarea { width: 100%; min-height: 100px; }
        input, textarea, button { margin-bottom: 10px; padding: 8px; }
        button { background-color: #4CAF50; color: white; border: none; cursor: pointer; }
        button:hover { background-color: #45a049; }
    </style>
</head>
<body>
<h1>Отзывы</h1>

<?php if (!empty($reviews)): ?>
    <?php foreach ($reviews as $review): ?>
        <div class="review">
            <h3><?= $review['name'] ?></h3>
            <div class="date"><?= $review['date'] ?></div>
            <p><?= nl2br($review['message']) ?></p>
        </div>
    <?php endforeach; ?>
<?php else: ?>
    <p>Пока нет отзывов. Будьте первым!</p>
<?php endif; ?>

<h2>Оставить отзыв</h2>
<form method="POST">
    <div>
        <input type="text" name="name" placeholder="Ваше имя" required>
    </div>
    <div>
        <textarea name="message" placeholder="Ваш отзыв" required></textarea>
    </div>
    <div>
        <button type="submit">Отправить</button>
    </div>
</form>
</body>
</html>