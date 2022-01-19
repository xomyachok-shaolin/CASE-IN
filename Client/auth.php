<?php
    require "script.php";
    if (isset($_COOKIE["login"]) == TRUE) {
        $login = $_COOKIE['login'];
        $pass = $_COOKIE['password'];
    }
    else {
        $login = $_REQUEST['login'];
        $pass = $_REQUEST['password'];
        if (isset($_REQUEST['remembered'])) {
            setcookie("login", $login, time() + 3600);
            setcookie("password", $pass, time() + 3600);
        }
    }
    $db = auth($login, $pass);
?>
<html>
<head>
<meta charset="utf-8" />
<script src="script.js"></script>
<link rel="stylesheet" type="text/css" href="style.css" >
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<title>IS</title>
</head>
<body>
    <form action="index.php" method="post">
        <input type="submit" name="logout" value="Выйти из системы" class="btn btn-mini btn-danger" />
    </form>
    <?php if($db == TRUE): ?>
        <!-- <p><a class="btn btn-link" href="machines.php">Станки</a></p> -->
        <p><a class="btn btn-link" href="jz_nachalnik_uchastka.php">Журнал заявок (начальник участка)</a></p>
        <p><a class="btn btn-link" href="jz_nachalnik_brigady.php">Журнал обслуживания (начальник ремонтной службы)</a></p>
        <p><a class="btn btn-link" href="boss.php">Журнал обслуживания</a></p>
        <p><a class="btn btn-link" href="employees.php">План работ</a></p>
    <?php else: ?>
        <h2>Ошибка подключения к Базе Данных!</h2>
    <?php endif ?>
</body>
</html>