<?php
    $words = array_slice($argv, 1);
    $maxLength = max(array_map('strlen', $words));
    $longestWords = [];
    for ($i = 0; $i < count($words); $i++) {
        if (strlen($words[$i]) == $maxLength) {
            $longestWords[] = $words[$i];
        }
    }

    echo "Самые длинные слова: " . implode(', ', $longestWords) . "\n";
?>