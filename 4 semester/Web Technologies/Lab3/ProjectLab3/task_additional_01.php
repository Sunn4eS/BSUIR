Устранение дубликатов из произвольного многомерного массива
(например, если в таком массиве пять раз встречается число 100,
оно должно остаться в массиве в одном экземпляре).


<?php
function removeDuplicates(&$array, &$uniqueValues = []) {

    foreach ($array as $key => &$value) {

        if (is_array($value)) {
            removeDuplicates($value, $uniqueValues);
        } else {

            if (in_array($value, $uniqueValues, true)) {

                unset($array[$key]);
            } else {

                $uniqueValues[] = $value;
            }
        }
    }
}

$inputArray = [
    [100, "100", 100],
    [300, 100, 400],
    [200, [100, 500, "100"], 600],
    [700, 800, [900, 100]]
];
removeDuplicates($inputArray);
print_r($inputArray);
?>
