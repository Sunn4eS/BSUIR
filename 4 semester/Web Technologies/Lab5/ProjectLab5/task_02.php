<?php
class DirectorySizeCalculator {
    private string $directory;

    public function __construct(string $directory) {
        $this->directory = $directory;
    }

    public function getTotalSize(): int {
        return $this->calculateSize($this->directory);
    }

    private function calculateSize(string $dir): int {
        $totalSize = 0;
        $items = scandir($dir);

        foreach ($items as $item) {
            if ($item === '.' || $item === '..') continue;

            $path = $dir . DIRECTORY_SEPARATOR . $item;

            if (is_file($path)) {
                $totalSize += filesize($path);
            } elseif (is_dir($path)) {
                $totalSize += $this->calculateSize($path);
            }
        }

        return $totalSize;
    }

    public function getFormattedSize(): string {
        $size = $this->getTotalSize();
        $units = ['Б', 'КБ', 'МБ', 'ГБ', 'ТБ'];
        $i = 0;

        while ($size >= 1024 && $i < count($units) - 1) {
            $size /= 1024;
            $i++;
        }

        return round($size, 2) . ' ' . $units[$i];
    }
}

$calculator = new DirectorySizeCalculator('/home/sasha'); // Можно указать любой путь
echo "Суммарный объём: " . $calculator->getFormattedSize();

