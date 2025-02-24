<?php
function generateColor($step, $totalSteps) {
    $shade = intval(($step / $totalSteps) * 255);
    return sprintf("#%02x%02x%02x", $shade, $shade, $shade);
}

// Получение количества строк из командной строки
$numRows = isset($argv[1]) ? intval($argv[1]) : 10; // По умолчанию 10 строк


$file = fopen('generated_gradient.html', "w");
fwrite($file, "<!Doctype html>\n");
fwrite($file, "<html lang=\"en\">\n");
fwrite($file, "<head>\n");
fwrite($file, "<meta charset=\"utf-8\" />\n");
fwrite($file, "<title> Task_02 </title>\n");
fwrite($file, "</head>\n");
fwrite($file, "<body>\n");
fwrite($file, "<table border=\"1\">\n");
for ($i = 0; $i < $numRows - 1; $i++) {
    $color = generateColor($i, $numRows - 1);
    fwrite($file, "<tr style='background-color: $color;'>");
    fwrite($file, "<td>Row " . ($i + 1) . "</td></tr>\n>");
}

fwrite($file, "</table>\n");
fwrite($file, "</body>\n");
fwrite($file, "</html>\n");

?>
