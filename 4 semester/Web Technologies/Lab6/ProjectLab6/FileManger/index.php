<?php
session_start();
require_once 'FileManager.php';
require_once 'AuthDb.php';

$auth = new AuthDb();
if (!$auth->isAuthenticated()) {
    header('Location: Login.php');
    exit;
}

$fm = new FileManager();
$message = '';

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['file'])) {
        $name = $fm->upload($_FILES['file']);
        $message = "Файл '{$name}' загружен.";
    }

    if (isset($_GET['delete'])) {
        $fm->delete($_GET['delete']);
        $message = "Файл '" . htmlspecialchars($_GET['delete']) . "' удалён.";
    }

    if (isset($_GET['download'])) {
        $file = $fm->getFilePath($_GET['download']);
        if (!file_exists($file)) throw new RuntimeException("Файл не найден.");
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . basename($file) . '"');
        header('Content-Length: ' . filesize($file));
        readfile($file);
        exit;
    }
} catch (Exception $e) {
    $message = "Ошибка: " . $e->getMessage();
}
?>

    <h3>Файловый менеджер | Пользователь: <?= htmlspecialchars($auth->getUser()) ?></h3>
    <a href="Logout.php">Выйти</a>

    <p><?= $message ?></p>

    <form method="post" enctype="multipart/form-data">
        <input type="file" name="file" required>
        <button type="submit">Загрузить</button>
    </form>

    <ul>
        <?php foreach ($fm->listFiles() as $file): ?>
            <li>
                <?= htmlspecialchars($file) ?>
                [<a href="?download=<?= urlencode($file) ?>">Скачать</a>]
                [<a href="?delete=<?= urlencode($file) ?>" onclick="return confirm('Удалить?')">Удалить</a>]
            </li>
        <?php endforeach; ?>
    </ul>
<?php
