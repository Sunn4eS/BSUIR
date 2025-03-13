<?php
if ($argc < 2) {
    die("Использование: php insertion_sort.php <имя_файла>\n");
}

$filename = $argv[1];

// Проверяем, существует ли файл
if (!file_exists($filename)) {
    die("Файл '$filename' не существует.\n");
}

// Читаем содержимое файла в массив строк
$lines = file($filename, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

if ($lines === false) {
    die("Не удалось прочитать файл '$filename'.\n");
}

// Реализация сортировки вставками
function insertionSort(array $arr): array {
    $n = count($arr);
    for ($i = 1; $i < $n; $i++) {
        $key = $arr[$i]; // Текущий элемент, который нужно вставить
        $j = $i - 1;

        // Сдвигаем элементы, которые больше $key, на одну позицию вправо
        while ($j >= 0 && strcmp($arr[$j], $key) > 0) {
            $arr[$j + 1] = $arr[$j];
            $j--;
        }
        // Вставляем $key в правильное место
        $arr[$j + 1] = $key;
    }
    return $arr;
}

// Сортируем строки с помощью сортировки вставками
$lines = insertionSort($lines);

// Записываем отсортированные строки обратно в файл
file_put_contents($filename, implode("\n", $lines) . "\n");

echo "Строки в файле '$filename' были отсортированы по алфавиту.\n";
?>