<?php
class ArrayFlattener {
    private array $inputArray;

    public function __construct(array $inputArray) {
        $this->inputArray = $inputArray;
    }

    public function flattenAndUnique(): array {
        $flat = $this->flatten($this->inputArray);
        return array_values(array_unique($flat)); // удаляем дубликаты и пересобираем индексы
    }

    private function flatten(array $array): array {
        $result = [];

        foreach ($array as $item) {
            if (is_array($item)) {
                $result = array_merge($result, $this->flatten($item)); // рекурсивное разворачивание
            } else {
                $result[] = $item;
            }
        }

        return $result;
    }
}

$nestedArray = [
    1,
    [2, 3, [4, 5, 1]],
    6,
    [2, [3, 7]]
];

$flattener = new ArrayFlattener($nestedArray);
$flatUniqueArray = $flattener->flattenAndUnique();

echo "Результат: ";
print_r($flatUniqueArray);
