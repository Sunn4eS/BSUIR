<!DOCTYPE html>
<html>
<head>
    <title>Отправка сообщения</title>
</head>
<body>

<h1>Отправить сообщение</h1>

<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $recipients_str = isset($_POST['recipients']) ? trim($_POST['recipients']) : '';
    $subject = isset($_POST['subject']) ? trim($_POST['subject']) : '';
    $message_text = isset($_POST['message']) ? trim($_POST['message']) : '';
    $errors = [];
    $recipients_array = [];

    // Проверка поля "Получатели"
    if (empty($recipients_str)) {
        $errors[] = "Поле 'Получатели' не может быть пустым.";
    } else {
        // Разделение получателей по пробелу, запятой или точке с запятой
        $delimiters = [' ', ',', ';'];
        $recipients = preg_split('/(' . implode('|', array_map('preg_quote', $delimiters)) . ')+/', $recipients_str);
        $valid_recipients = [];
        foreach ($recipients as $recipient) {
            $recipient = trim($recipient);
            if (!empty($recipient) && filter_var($recipient, FILTER_VALIDATE_EMAIL)) {
                $valid_recipients[] = $recipient;
            } elseif (!empty($recipient)) {
                $errors[] = "Некорректный адрес электронной почты: " . htmlspecialchars($recipient);
            }
        }
        if (empty($valid_recipients) && empty($errors)) {
            $errors[] = "Не указано ни одного корректного адреса электронной почты.";
        }
        $recipients_array = $valid_recipients;
    }

    // Проверка поля "Тема"
    if (empty($subject)) {
        $errors[] = "Поле 'Тема' не может быть пустым.";
    }

    // Проверка поля "Текст сообщения"
    if (empty($message_text)) {
        $errors[] = "Поле 'Текст сообщения' не может быть пустым.";
    }

    if (!empty($errors)) {
        echo "<div style='color: red;'>";
        echo "<h2>Ошибка!</h2>";
        foreach ($errors as $error) {
            echo "<p>" . htmlspecialchars($error) . "</p>";
        }
        echo "</div>";
        // Сохраняем введенные значения для повторного отображения в форме
        $saved_recipients = htmlspecialchars($recipients_str);
        $saved_subject = htmlspecialchars($subject);
        $saved_message = htmlspecialchars($message_text);
    } else {
        $all_sent = true;
        foreach ($recipients_array as $recipient) {
            $headers = 'From: webmaster@example.com' . "\r\n" .
                'Reply-To: webmaster@example.com' . "\r\n" .
                'X-Mailer: PHP/' . phpversion();

            if (!mail($recipient, $subject, $message_text, $headers)) {
                echo "<div style='color: orange;'>";
                echo "<p>Не удалось отправить сообщение на адрес: " . htmlspecialchars($recipient) . "</p>";
                echo "</div>";
                $all_sent = false;
            }
        }

        if ($all_sent && !empty($recipients_array)) {
            echo "<div style='color: green;'>";
            echo "<h2>Сообщение успешно отправлено!</h2>";
            echo "</div>";

            // Сохранение списка получателей в файл
            $filename = 'recipients_list.txt';
            $file = fopen($filename, 'a');
            if ($file) {
                fwrite($file, date('Y-m-d H:i:s') . " - " . implode(', ', $recipients_array) . "\n");
                fclose($file);
                echo "<p>Список получателей сохранен в файле: " . htmlspecialchars($filename) . "</p>";
            } else {
                echo "<div style='color: orange;'>";
                echo "<p>Не удалось сохранить список получателей.</p>";
                echo "</div>";
            }
        } elseif (empty($recipients_array) && empty($errors)) {
            echo "<div style='color: orange;'>";
            echo "<p>Нет корректных адресов для отправки.</p>";
            echo "</div>";
        }

        // Очищаем значения после успешной отправки
        $saved_recipients = '';
        $saved_subject = '';
        $saved_message = '';
    }
} else {
    $saved_recipients = '';
    $saved_subject = '';
    $saved_message = '';
}
?>

<form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
    <div>
        <label for="recipients">Получатели (через пробел, запятую или точку с запятой):</label><br>
        <textarea id="recipients" name="recipients" rows="3" cols="50"><?php echo $saved_recipients; ?></textarea>
    </div>
    <br>
    <div>
        <label for="subject">Тема:</label><br>
        <input type="text" id="subject" name="subject" size="50" value="<?php echo $saved_subject; ?>">
    </div>
    <br>
    <div>
        <label for="message">Текст сообщения:</label><br>
        <textarea id="message" name="message" rows="10" cols="50"><?php echo $saved_message; ?></textarea>
    </div>
    <br>
    <button type="submit">Отправить</button>
</form>

</body>
</html>