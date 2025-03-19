<?php
function createAcademicCalendar($year) {

    $startDate = new DateTime("$year-09-01");


    $endDate = new DateTime("$year-12-31");
    $endDate->modify('+1 year');


    $holidays = [
        ['start' => "$year-10-30", 'end' => "$year-11-07"],
        ['start' => "$year-12-25", 'end' => ($year + 1) . "-01-10"],
        ['start' => ($year + 1) . "-03-25", 'end' => ($year + 1) . "-04-02"],
        ['start' => ($year + 1) . "-06-01", 'end' => ($year + 1) . "-06-30"],
    ];

    $sessions = [
        ['start' => ($year + 1) . "-01-15", 'end' => ($year + 1) . "-01-30"],
        ['start' => ($year + 1) . "-05-15", 'end' => ($year + 1) . "-05-30"],
    ];

    $html = "<!DOCTYPE html>
    <html lang='ru'>
    <head>
        <meta charset='UTF-8'>
        <title>Календарь учебного года $year-$year+1</title>
        <style>
            .holiday { font-weight: bold; color: red; }
            .session { font-weight: bold; color: blue; }
        </style>
    </head>
    <body>
        <h1>Календарь учебного года $year-$year+1 (Курс $course)</h1>
        <table border='1'>
            <tr>
                <th>Неделя</th>
                <th>Дата начала</th>
                <th>Дата окончания</th>
                <th>Примечание</th>
            </tr>";

    $weekNumber = 1;
    $currentDate = clone $startDate;

    while ($currentDate <= $endDate) {
        $weekStart = clone $currentDate;
        $weekEnd = clone $currentDate;
        $weekEnd->modify('+6 days');

        $note = '';
        $class = '';

        foreach ($holidays as $holiday) {
            $holidayStart = new DateTime($holiday['start']);
            $holidayEnd = new DateTime($holiday['end']);

            if ($weekStart <= $holidayEnd && $weekEnd >= $holidayStart) {
                $note = 'Каникулы';
                $class = 'holiday';
                break;
            }
        }

        foreach ($sessions as $session) {
            $sessionStart = new DateTime($session['start']);
            $sessionEnd = new DateTime($session['end']);

            if ($weekStart <= $sessionEnd && $weekEnd >= $sessionStart) {
                $note = 'Сессия';
                $class = 'session';
                break;
            }
        }

        $html .= "<tr class='$class'>
            <td>$weekNumber</td>
            <td>{$weekStart->format('Y-m-d')}</td>
            <td>{$weekEnd->format('Y-m-d')}</td>
            <td>$note</td>
        </tr>";

        $currentDate->modify('+1 week');
        $weekNumber = ($weekNumber % 4) + 1;
    }

    $html .= "</table></body></html>";

    $filename = "academic_calendar_$year.html";
    file_put_contents($filename, $html);

    return $filename;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $year = intval($_POST['year']);
    $course = intval($_POST['course']);

    $filename = createAcademicCalendar($year, $course);

    echo "Календарь успешно создан. <a href='$filename'>Открыть календарь</a>";
}
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Форма для создания календаря</title>
</head>
<body>
<h1>Создание календаря учебного года</h1>
<form method="post">
    <label for="year">Год:</label>
    <input type="number" id="year" name="year" required>
    <br>
    <label for="course">Курс:</label>
    <input type="number" id="course" name="course" min="1" max="4" required>
    <br>
    <button type="submit">Создать календарь</button>
</form>
</body>
</html>