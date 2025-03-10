<!DOCTYPE html>
<html lang="ru" xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Меню с активными ссылками</title>
    <style>
        body {
            font-family: Arial, sans-serif;
        }
        .menu {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        .menu a {
            text-decoration: none;
            color: #333;
            padding: 5px 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .menu a.active {
            background-color: #4CAF50;
            color: white;
            border-color: #4CAF50;
        }
    </style>
</head>
<body>

<?php
    $active_page = isset($_GET['page']) ? $_GET['page'] : 'about';
?>
<div class="menu">

    <a href="?page=about" class="<?php echo $active_page == 'about' ? 'active' : ''; ?>">О компании</a>
    <a href="?page=services" class="<?php echo $active_page == 'services' ? 'active' : ''; ?>">Услуги</a>
    <a href="?page=pricing" class="<?php echo $active_page == 'pricing' ? 'active' : ''; ?>">Прайс</a>
    <a href="?page=contacts" class="<?php echo $active_page == 'contacts' ? 'active' : ''; ?>">Контакты</a>
    <a href="?page=task" class="<?php echo $active_page == 'task' ? 'active' : ''; ?>">Задание варианта 5</a>
</div>


<?php
    $content = [
        'about' => "<h2>О компании</h2><p>Информация о компании.</p>",
        'services' => "<h2>Услуги</h2><p>Список доступных услуг.</p>",
        'pricing' => "<h2>Прайс</h2><p>Цены для различных видов услуг</p>",
        'contacts' => "<h2>Контакты</h2><p>Контактные данные</p>",
        'task' => 'task5.php'
    ];

    if (!array_key_exists($active_page, $content)) {
        $active_page = 'about';
    }
    if ($active_page == 'task') {
        $taskFile = $content['task'];
        include $taskFile;
    }
    else {
        echo $content[$active_page];
    }
    ?>


</body>
</html>