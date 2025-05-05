<?php
session_start();
require_once 'AuthDb.php';

$auth = new AuthDb();
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if ($auth->login($_POST['login'], $_POST['password'])) {
        header('Location: index.php');
        exit;
    } else {
        $error = "Неверный логин или пароль.";
    }
}
?>

<h3>Вход</h3>
<?php if ($error): ?><p style="color:red"><?= htmlspecialchars($error) ?></p><?php endif; ?>
<form method="post">
    <input name="login" placeholder="Логин" required><br>
    <input name="password" type="password" placeholder="Пароль" required><br>
    <button type="submit">Войти</button>
</form>
