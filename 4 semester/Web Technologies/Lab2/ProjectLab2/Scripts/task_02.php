<?php
    if ($argc < 2) {
        echo "You need 2 parameters.\nphp task_02.php <number of lines>\n";
        exit;
    }
    $numberOfRows = $argv[1];
    if (!is_numeric($numberOfRows)) {
        echo "You need a number.\n";
    } else {
        $numberOfRows = intval($numberOfRows);
        $file = fopen('generated_table.html', "w");
        fwrite($file, "<!Doctype html>\n");
        fwrite($file, "<html lang=\"en\">\n");
        fwrite($file, "<head>\n");
        fwrite($file, "<meta charset=\"utf-8\" />\n");
        fwrite($file, "<title> Task_02 </title>\n");
        fwrite($file, "</head>\n");
        fwrite($file, "<body>\n");
        fwrite($file, "<table border=\"1\">\n");
        fwrite($file, "<tr><th>Row Number</th></tr>>\n");
        for ($row = 1; $row <= $numberOfRows; $row++) {
            fwrite($file, "<tr><td>Row $row </td></tr>>\n");
        }
        fwrite($file, "</table>\n");
        fwrite($file, "</body>\n");
        fwrite($file, "</html>\n");
    }

?>