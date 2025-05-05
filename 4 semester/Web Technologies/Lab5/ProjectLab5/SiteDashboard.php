<?php
// === НАСТРОЙКИ ПОДКЛЮЧЕНИЯ ===
define('DB_HOST', 'localhost');
define('DB_USER', 'sasha');
define('DB_PASS', '08062023');
define('DB_NAME', 'SitesDatabase');

$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
if ($mysqli->connect_error) die("Ошибка подключения: " . $mysqli->connect_error);
$mysqli->set_charset("utf8");

// === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===
function build_sitemap($parent_id = NULL, $level = 0) {
    global $mysqli;
    $query = "SELECT * FROM pages WHERE parent_id " . ($parent_id === NULL ? "IS NULL" : "= ?");
    $stmt = $mysqli->prepare($query);
    if ($parent_id !== NULL) $stmt->bind_param('i', $parent_id);
    $stmt->execute();
    $res = $stmt->get_result();
    while ($page = $res->fetch_assoc()) {
        echo str_repeat('&nbsp;', $level * 4) . "• <a href='{$page['url']}'>{$page['title']}</a><br>";
        build_sitemap($page['id'], $level + 1);
    }
}

function log_admin_action($admin_id, $action) {
    global $mysqli;
    $stmt = $mysqli->prepare("INSERT INTO admin_logs (admin_id, action) VALUES (?, ?)");
    $stmt->bind_param('is', $admin_id, $action);
    $stmt->execute();
}

// === ОПРОС (ГОЛОСОВАНИЕ) ===
$poll = $mysqli->query("SELECT * FROM polls ORDER BY id DESC LIMIT 1")->fetch_assoc();
$poll_answers = [];
if ($poll) {
    $res = $mysqli->query("SELECT * FROM poll_answers WHERE poll_id = " . $poll['id']);
    while ($row = $res->fetch_assoc()) $poll_answers[] = $row;
    if (isset($_POST['vote'])) {
        $answer_id = (int)$_POST['vote'];
        $mysqli->query("UPDATE poll_answers SET votes = votes + 1 WHERE id = $answer_id");
    }
}

// === ПОДПИСКА ===
if (isset($_POST['subscribe_email'])) {
    $email = $_POST['subscribe_email'];
    $stmt = $mysqli->prepare("INSERT IGNORE INTO subscribers (email) VALUES (?)");
    $stmt->bind_param('s', $email);
    $stmt->execute();
}

// === СЛУЧАЙНЫЙ БАННЕР ===
$banner = $mysqli->query("SELECT image_url FROM banners WHERE is_active = 1 ORDER BY RAND() LIMIT 1")->fetch_assoc();

// === ПОИСК ===
$search_results = [];
if (isset($_GET['search'])) {
    $term = "%" . $_GET['search'] . "%";
    $stmt = $mysqli->prepare('SELECT * FROM pages WHERE content LIKE "' . $term . '"');
 //   $stmt->bind_param('s', $term);
    $stmt->execute();
    $res = $stmt->get_result();
    while ($r = $res->fetch_assoc()) $search_results[] = $r;
}

// === HTML ===
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Панель сайта</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        h2 { margin-top: 40px; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        th, td { border: 1px solid #999; padding: 6px; text-align: left; }
        th { background: #eee; }
    </style>
</head>
<body>

<h1>Панель сайта</h1>

<!-- Карта сайта -->
<h2>Карта сайта</h2>
<?php build_sitemap(); ?>

<!-- Поиск -->
<h2>Поиск</h2>
<form method="get">
    <input type="text" name="search" placeholder="Поиск..." value="<?= htmlspecialchars($_GET['search'] ?? '') ?>">
    <button type="submit">Найти</button>
</form>
<?php if ($search_results): ?>
    <ul>
        <?php foreach ($search_results as $page): ?>
            <li><a href="<?= $page['url'] ?>"><?= $page['title'] ?></a></li>
        <?php endforeach; ?>
    </ul>
<?php endif; ?>

<!-- Баннер -->
<?php if ($banner): ?>
    <h2>Баннер</h2>
    <img src="<?= $banner['image_url'] ?>" alt="Баннер" style="max-width:300px;">
<?php endif; ?>

<!-- Опрос -->
<?php if ($poll): ?>
    <h2>Голосование: <?= $poll['question'] ?></h2>
    <form method="post">
        <?php foreach ($poll_answers as $a): ?>
            <div>
                <label>
                    <input type="radio" name="vote" value="<?= $a['id'] ?>"> <?= $a['answer'] ?> (<?= $a['votes'] ?> голосов)
                </label>
            </div>
        <?php endforeach; ?>
        <button type="submit">Голосовать</button>
    </form>
<?php endif; ?>

<!-- Подписка -->
<h2>Подписка на рассылку</h2>
<form method="post">
    <input type="email" name="subscribe_email" placeholder="Ваш email" required>
    <button type="submit">Подписаться</button>
</form>
</body>
</html>
