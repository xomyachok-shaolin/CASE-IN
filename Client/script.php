<?php
    static $db;
    $hostname = 'host=';
    $port = 'port=';
    $dbname = 'dbname=';
    $user = 'user=';
    $password = 'password=';
    function auth($login='postgres', $pass='Admin1992') {
        global $hostname, $port, $dbname, $user, $password;
        $hostname = $hostname . '192.168.0.108';
        $port = $port . '5432';
        $dbname = $dbname . 'CASE__IN';
        $user = $user . $login;
        $password = $password . $pass;
        $str = $hostname . ' ' . $port . ' ' . $dbname . ' ' . $user . ' ' . $password;
        $db = db_access($str);
        return $db;
    }
    function db_access($connect_str) {
        $db = pg_pconnect($connect_str);
        return $db;
    }
    function nulify_cookie() {
        setcookie("login", "", time() - 3600);
        setcookie("password", "", time() - 3600);
        unset($_COOKIE);
    }
?>