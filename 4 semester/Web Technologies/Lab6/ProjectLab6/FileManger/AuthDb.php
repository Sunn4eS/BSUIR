<?php

class AuthDb {
    private PDO $pdo;

    public function __construct() {
        try {
            $this->pdo = new PDO("mysql:host=localhost;dbname=file_manager;charset=utf8", "sasha", "08062023");
            $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $e) {
            die("Ошибка подключения к базе данных: " . $e->getMessage());
        }
    }

    public function login(string $login, string $password): bool {
        $stmt = $this->pdo->prepare("SELECT password FROM users WHERE username = ?");
        $stmt->execute([$login]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user && $user['password'] === $password) {
            $_SESSION['user'] = $login;
            return true;
        }

        return false;
    }

    public function logout(): void {
        session_destroy();
    }

    public function isAuthenticated(): bool {
        return isset($_SESSION['user']);
    }

    public function getUser(): ?string {
        return $_SESSION['user'] ?? null;
    }
}
