<?php
    function check_input($input) {
        if (is_numeric($input)) {
            if (strpos($input, '.') !== false) {
                return "дробное число\n";
            } else {
                return "целое число\n";
            }
        } else {
            return "строка\n";
        }
    }
    $params = $_GET;
    foreach ($params as $param => $value) {
        $type = check_input($value);
        echo "Параметр $param имеет значение такого типа: " . $type . "<br>";
    }
?>