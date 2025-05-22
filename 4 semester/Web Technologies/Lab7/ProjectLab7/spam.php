<?php
// Подключение классов PHPMailer вручную
require 'PHPMailer/PHPMailer.php';
require 'PHPMailer/SMTP.php';
require 'PHPMailer/Exception.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Данные из формы
$recipients = $_POST['recipients'] ?? '';
$subject = $_POST['subject'] ?? '';
$message = $_POST['message'] ?? '';
$errors = [];
$success = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $emails = preg_split('/[\s,;]+/', $recipients);
    $validEmails = [];

    foreach ($emails as $email) {
        if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $validEmails[] = $email;
        } else {
            $errors[] = "Неверный email: $email";
        }
    }

    if (empty($subject)) $errors[] = "Поле «Тема» обязательно.";
    if (empty($message)) $errors[] = "Поле «Текст сообщения» обязательно.";

    if (empty($errors)) {
        $mail = new PHPMailer(true);

        try {
            // Настройки SMTP
            $mail->isSMTP();
            //$mail->Host = 'smtp.gmail.com';
            $mail->SMTPAuth = true;
            $mail->Username = 'sashabrazhalovich2005@gmail.com';        // ← твой Gmail
            $mail->Password = '29945bsil';          // ← пароль приложения
            //$mail->SMTPSecure = 'tls';
            //$mail->Port = 587;
            $mail->Host = 'smtp.yandex.ru';
            $mail->Port = 465;
            $mail->SMTPSecure = 'ssl';


            $mail->CharSet = 'UTF-8';
            $mail->setFrom('youremail@gmail.com', 'Отправитель');

            foreach ($validEmails as $email) {
                $mail->addAddress($email);
            }

            $mail->Subject = $subject;
            $mail->Body = $message;

            $mail->send();

            // Сохраняем лог
            file_put_contents('recipients_log.txt', implode("\n", $validEmails) . "\n", FILE_APPEND);
            $success = true;
            $recipients = $subject = $message = '';
        } catch (Exception $e) {
            $errors[] = "Ошибка отправки: {$mail->ErrorInfo}";
        }
    }
}
?>

<!-- HTML-форма -->
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>PHPMailer без Composer</title>
</head>
<body>
<h2>Отправка писем через SMTP</h2>

<?php if ($success): ?>
    <p style="color: green;">Письма успешно отправлены!</p>
<?php endif; ?>

<?php if (!empty($errors)): ?>
    <ul style="color: red;">
        <?php foreach ($errors as $error): ?>
            <li><?= htmlspecialchars($error) ?></li>
        <?php endforeach; ?>
    </ul>
<?php endif; ?>

<form method="post">
    <label>Получатели:</label><br>
    <textarea name="recipients" rows="3" cols="60"><?= htmlspecialchars($recipients) ?></textarea><br><br>

    <label>Тема:</label><br>
    <input type="text" name="subject" size="60" value="<?= htmlspecialchars($subject) ?>"><br><br>

    <label>Текст сообщения:</label><br>
    <textarea name="message" rows="10" cols="60"><?= htmlspecialchars($message) ?></textarea><br><br>

    <input type="submit" value="Отправить">
</form>
</body>
</html>
