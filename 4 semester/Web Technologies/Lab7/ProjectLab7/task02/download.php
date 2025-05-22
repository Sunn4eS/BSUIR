<?php
include_once '../task01/ImageDownloader.php';

$results = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['url'])) {
    $url = filter_var(trim($_POST['url']), FILTER_VALIDATE_URL);
    $localDir = rtrim(__DIR__ . '/images', '/');
    $max = (int) ($_POST['max'] ?? 5);
    $maxLinks = (int) ($_POST['maxLinks'] ?? 3);

    if ($url) {
        $downloader = new ImageDownloader();
        $results = $downloader->download($url, $max, $maxLinks, $localDir);
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
    <h1>📦 Результат загрузки</h1>

    <?php
    if (!empty($results)) {
        foreach ($results as $line) {
            echo $line . "\n";
        }
    } else {
        echo "<p class='error'>⚠️ Нет результатов для отображения.</p>";
    }
    ?>
</div>
</body>
</html>
