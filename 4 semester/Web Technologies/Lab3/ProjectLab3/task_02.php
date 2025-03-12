<?php
if (isset($_GET['text'])) {
    $text = $_GET['text'];

    $words = array_filter(explode(' ', $text), function($word) {
        return !empty($word); // Убираем пустые элементы
    });

    foreach ($words as $key => $word) {
        if (($key + 1) % 3 == 0) {
            $words[$key] = strtoupper($words[$key]);
        }

        $letters = str_split($word);
        foreach ($letters as $letterKey => $letter) {
            if (($letterKey + 1) % 3 == 0) {
                $letters[$letterKey] = '<span style="color: purple;">' . $letter . '</span>';
            }
        }
        $words[$key] = implode('', $letters);
    }
    $modifiedText = implode(' ', $words);

    echo $modifiedText;
} else {
    echo "Пожалуйста, передайте текст через GET-запрос, используя параметр 'text'.";
}
?>