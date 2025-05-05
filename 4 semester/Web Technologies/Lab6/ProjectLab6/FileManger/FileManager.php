<?php
class FileManager
{
    private string $uploadDir;
    public function __construct(string $uploadDir = 'uploads'){
        $this->uploadDir = $uploadDir;
        if (!is_dir($this->uploadDir)) {
            mkdir($this->uploadDir, 0777, true);
        }
    }
    public function upload(array $data): string {
        if ($data['error'] !== UPLOAD_ERR_OK) {
            throw new RuntimeException("Upload error: " . $data['error']);
        }

        $filename = basename($data['name']); // не $data['file']
        $target_file = $this->uploadDir . DIRECTORY_SEPARATOR . $filename;

        if (!move_uploaded_file($data['tmp_name'], $target_file)) {
            throw new RuntimeException("Save error");
        }

        return $filename;
    }


    public function delete(string $filename): bool {
        $filepath = $this->uploadDir . DIRECTORY_SEPARATOR . basename($filename);
        if (!file_exists($filepath)) {
            throw new RuntimeException("File not found");
        }
        return unlink($filepath);
    }
    public function getFilePath(string $filename): string {
        return $this->uploadDir . DIRECTORY_SEPARATOR . basename($filename);
    }

    public function listFiles(): array {
        return array_values(array_filter(scandir($this->uploadDir), function ($file) {return $file != '.' && $file != '..';}));
    }

}