<?php
class SmartDate {
    private $date;
    public function __construct($dateString) {
        $this->date = $dateString;
    }
    public function isWeekend(): bool {
        $dayOfWeek = date('N', strtotime($this->date));
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

        }

    }
}

