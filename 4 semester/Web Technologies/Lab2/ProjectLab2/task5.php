<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Поле для ввода текста</title>
</head>
<body>
<form method="post">

    <label for="sentence">
        <p>Введите ряд слов через запятую</p>
        <p>Первое слово должно быть с большой буквы</p>
        <p>в конце ряда должна быть точка</p>
    </label>
    <input type="text" id="sentence" name="t_edit">
    <button type="submit">Подтвердить</button>
</form>
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sentence = isset($_POST['t_edit']) ? htmlspecialchars($_POST['t_edit']) : '';

    function checkInput($input_sentence): bool
    {
        if (!empty($input_sentence)) {
            if (preg_match('/^[A-ZА-Я].*\.$/u', $input_sentence)) {
                echo "<p>Вы ввели: <strong>$input_sentence</strong></p>";
                return true;
            } else {
                echo "<p>Строка должна начинаться с заглавной буквы и кончаться точкой!</p>";
            }
        } else {
            echo "<p>Поле не заполнено.</p>";
        }
        return false;
    }

    function newstring($input_sentence): string
    {


        $firstChar = mb_substr($input_sentence, 0, 1, 'UTF-8');
        $restOfString = mb_substr($input_sentence, 1, null, 'UTF-8');
        $new_string = mb_strtolower($firstChar, 'UTF-8') . $restOfString;
        $new_string = rtrim($new_string, '.');

        $words = explode(',', $new_string);
        for ($i = 0; $i < count($words); $i++) {
            $words[$i] = trim($words[$i]);
        }
        $reversed = [];
        for ($i = count($words) - 1; $i >= 0; $i--) {
            $reversed[] = $words[$i];
        }
        $new_string = implode(', ', $reversed);
        $new_string = mb_strtoupper(mb_substr($new_string, 0, 1, 'UTF-8'), 'UTF-8') . mb_substr($new_string, 1, null, 'UTF-8') . '.';

        return $new_string;
    }


     if (checkInput($sentence)) {
       echo "Новая строка: " . newstring($sentence);
     }
}
?>
</body>
</html>