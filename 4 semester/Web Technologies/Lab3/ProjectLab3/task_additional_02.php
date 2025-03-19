<?php
if ($argc < 2) {
    die("Использование: php insertion_sort.php <имя_файла>\n");
}

$filename = $argv[1];

if (!file_exists($filename)) {
    die("Файл '$filename' не существует.\n");
}


$lines = file($filename, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

if ($lines === false) {
    die("Не удалось прочитать файл '$filename'.\n");
}


function insertionSort(array $arr): array {
    $n = count($arr);
    for ($i = 1; $i < $n; $i++) {
        $key = $arr[$i];
        $j = $i - 1;


        while ($j >= 0 && strcmp($arr[$j], $key) > 0) {
            $arr[$j + 1] = $arr[$j];
            $j--;
        }

        $arr[$j + 1] = $key;
    }
    return $arr;
}

$lines = insertionSort($lines);


file_put_contents($filename, implode("\n", $lines) . "\n");

echo "Строки в файле '$filename' были отсортированы по алфавиту.\n";
?>