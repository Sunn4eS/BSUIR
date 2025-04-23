<?php
class DuplicateFileFinder {
    private string $directory;
    private array $hashMap = [];

    public function __construct(string $directory) {
        $this->directory = $directory;
    }

    public function findDuplicates(): array {
        $this->scanDirectory($this->directory);

        $duplicates = [];
        foreach ($this->hashMap as $hash => $files) {
            if (count($files) > 1) {
                $duplicates[$hash] = $files;
            }
        }

        return $duplicates;
    }

    private function scanDirectory(string $dir): void {
        if (!is_readable($dir)) return;

        $items = scandir($dir);
        if (!$items) return;

        foreach ($items as $item) {
            if ($item === '.' || $item === '..') continue;

            $path = $dir . DIRECTORY_SEPARATOR . $item;

            if (is_file($path) && is_readable($path)) {
                $hash = md5_file($path);
                $this->hashMap[$hash][] = $path;
            } elseif (is_dir($path)) {
                $this->scanDirectory($path);
            }
        }
    }
}

$dir = '/home'; // Путь к папке для анализа
$finder = new DuplicateFileFinder($dir);
$duplicates = $finder->findDuplicates();

if (empty($duplicates)) {
    echo "Дубликаты не найдены.";
} else {
    echo "Найдены дубликаты:\n";
    foreach ($duplicates as $hash => $files) {
        echo "Хеш: $hash\n";
        foreach ($files as $file) {
            echo " - $file\n";
        }
        echo "\n";
    }
}
