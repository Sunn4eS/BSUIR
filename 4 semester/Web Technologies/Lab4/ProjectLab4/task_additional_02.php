<?php
class FileSystemObject {
    private string $path;
    private int $size;
    private string $type;
    public function __construct(string $name) {
        $this->path = $name;
        $this->size = filesize($this->path);
        $this->type = is_dir($this->path)?'dir':'file';
    }
    public function getSize($unit = 'B'): float {
        switch (strtoupper($unit)) {
            case 'KB':
                return round($this->size / 1024, 2);
                case 'MB':
                    return round($this->size / (1024 ** 2), 2);
                    case 'GB':
                        return round($this->size / (1024 ** 3), 2);
            default:
                return round($this->size, 2);
        }
    }
    public function getType(): string {
        return $this->type;
    }
    public function getPath(): string {
        return $this->path;
    }
}


$directory = $argv[2] ?? getcwd(); // Если не передан аргумент, используем текущий каталог

// Проверяем, существует ли указанная директория
if (!is_dir($directory)) {
    echo "Ошибка: Директория '$directory' не существует.\n";
    exit(1);
}

// Получаем список всех файлов и директорий в указанной директории
$files = scandir($directory);

// Фильтруем файлы и директории, убирая . и ..
$files = array_filter($files, function ($file) use ($directory) {
    return $file !== '.' && $file !== '..' && is_file($directory . DIRECTORY_SEPARATOR . $file);
});

// Выводим имена файлов и их размеры в MB
foreach ($files as $file) {
    $fileObj = new FileSystemObject($directory . DIRECTORY_SEPARATOR . $file);
    echo "Файл: " . $fileObj->getPath() . " | Размер: " . number_format($fileObj->getSize($argv[1]), 2) . " $argv[1]\n";
}