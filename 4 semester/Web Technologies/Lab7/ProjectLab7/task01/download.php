<?php
include_once './ImageDownloader.php';

$results = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['url'])) {
    $url = filter_var(trim($_POST['url']), FILTER_VALIDATE_URL);
    $localDir = rtrim(__DIR__ . '/images', '/');
    $max = (int) ($_POST['max'] ?? 5);

    if ($url) {
        $downloader = new ImageDownloader();
        $results = $downloader->downloadFromPage($url, $max, $localDir, "images");
    } else {
        $results[] = "<p style='color:red;'>❌ Неверный URL</p>";
    }
}
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Результат загрузки</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <h1>🖼️ Результат загрузки</h1>

    <?php if (!empty($results)): ?>
        <div class="result">
            <?php
            foreach ($results as $line) {
                echo $line . "\n";
            }
            ?>
        </div>
    <?php else: ?>
        <p>Форма недоступна напрямую. Перейдите на <a href="index.html">главную страницу</a>.</p>
    <?php endif; ?>
</div>
</body>
</html>
