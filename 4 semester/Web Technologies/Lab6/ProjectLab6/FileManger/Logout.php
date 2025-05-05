<?php
session_start();
require_once 'AuthDb.php'; // Или AuthFile.php
$auth = new AuthDb();
$auth->logout();
header('Location: Login.php');
