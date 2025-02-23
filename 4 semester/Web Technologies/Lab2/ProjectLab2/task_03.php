<?php
    $count = 0;
    function generate_array($levels, $elementsPerLevel) {
        global $count;
        if ($levels == 0) {
            return $count++;
        }
        $array = [];
        for ($i = 0; $i < $elementsPerLevel; $i++) {
           $array[] = generate_array($levels - 1, $elementsPerLevel);
        }
        return $array;
    }

function displayArray($array, $level = 0) {
    $colors = ['red', 'blue', 'green', 'purple', 'yellow', 'black', 'orange', 'black'];

    if (!is_array($array)) {
        echo "<span style='color: " . $colors[min($level, count($colors) - 1)] . "'>$array</span>";
        return;
    }

    echo "<ul style='color: " . $colors[min($level, count($colors) - 1)] . "'>";
    foreach ($array as $element) {
        echo "<li>";
        displayArray($element, $level + 1);
        echo "</li>";
    }
    echo "</ul>";
}
$newArray = generate_array(6, 5);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Generated Array</title>
</head>
<body>
<?php displayArray($newArray);?>
</body>
</html>