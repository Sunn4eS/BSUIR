<?php
class SmartDate {
    private $date;
    public function __construct($dateString) {
        $this->date = new DateTime($dateString);
    }
    public function isWeekend(): bool {
        $dayOfWeek = (int)$this->date->format('N');
        return $dayOfWeek >= 6;
    }

    public function getDistanceFromToday($unit = 'days'): int {
        $today = new DateTime();
        $interval = $today->diff($this->date);
        switch ($unit) {
            case 'days':
                return $interval->days;
            case 'months':
                return $interval->y * 12 + $interval->m;
            case 'years':
                return $interval->y;
            default:
                throw new InvalidArgumentException("Неподдерживаемая единица измерения: $unit");
        }
    }
    public function isLeapYear(): bool {
        $year = (int)$this->date->format('Y');
        return $year % 400 === 0;
    }

    public function __toString(): string {
        return $this->date->format('Y-m-d');
    }
}
$newdate = new SmartDate($argv[1]);
echo "Дата: $newdate\n";
echo "Выходной: ". ($newdate->isWeekend() ? 'Да' : 'Нет') . "\n";
echo "Дней до сегодня:" . $newdate->getDistanceFromToday() . "\n";
echo "Високосный год: " . ($newdate->isLeapYear() ? 'Да' : 'Нет') . "\n";