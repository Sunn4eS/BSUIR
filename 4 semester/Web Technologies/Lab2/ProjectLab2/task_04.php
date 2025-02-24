<?php
    $num = $argv[1];
    function calc_sum($num) {
        $temp = $num;
        $sum = 0;

        while ($temp != 0) {
            $temp = $temp % 10;
            $num = $num / 10;
            $sum = $sum + $temp;
            $temp = $num;
        }
        echo "Сумма равна $sum\n";
    }
    if (is_numeric($num)) {
        calc_sum($num);
    } else {
        echo "Неврный формат двнных.\n";
    }
?>
