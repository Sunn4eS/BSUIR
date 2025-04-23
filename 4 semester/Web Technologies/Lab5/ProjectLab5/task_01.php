<?php
class AgeCalculator {
    private DateTime $birthDate;

    public function __construct(string $birthDateStr) {
        $this->birthDate = new DateTime($birthDateStr);
    }

    public function getAge(): string {
        $today = new DateTime();
        $age = $today->diff($this->birthDate);
        return "{$age->y} лет, {$age->m} месяцев, {$age->d} дней";
    }
}
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Расчёт возраста (ООП)</title>
</head>
<body>
<h2>Введите дату рождения</h2>
<form method="post">
    <input type="date" name="birthdate" required>
    <button type="submit">Рассчитать</button>
</form>

<?php
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['birthdate'])) {
    $birthDate = $_POST['birthdate'];
    $calculator = new AgeCalculator($birthDate);
    echo "<p>Возраст: " . $calculator->getAge() . "</p>";
}
?>
</body>
</html>
