<?php

foreach ($argv as $key => $value) {
    if ($key == 0) continue;
    if (is_numeric($value)) {
        if (strpos($value, '.') !== false) {
            echo $value . " дробное число\n";
        } else {
            echo $value . " целое число\n";
        }
    } else {
        echo $value . " имеет строковое значение\n";
    }
}
?>
