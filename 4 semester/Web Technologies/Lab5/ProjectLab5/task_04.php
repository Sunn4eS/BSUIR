<?php
class LetterCounter {
    private string $text;

    public function __construct(string $text) {
        $this->text = mb_strtolower($text); // приводим к нижнему регистру
    }

    public function countLetters(): array {
        $lettersOnly = preg_replace('/[^a-zа-яё]/u', '', $this->text); // оставляем только буквы (англ. и рус.)
        $counts = [];

        foreach (mb_str_split($lettersOnly) as $char) {
            if (isset($counts[$char])) {
                $counts[$char]++;
            } else {
                $counts[$char] = 1;
            }
        }

        ksort($counts);
        return $counts;
    }
}

$text = "тест";
$counter = new LetterCounter($text);
$letterCounts = $counter->countLetters();

echo "Статистика букв:\n";
foreach ($letterCounts as $letter => $count) {
    echo "Буква '$letter' встречается $count раз(а)\n";
}
