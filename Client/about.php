<html>
<head>
<meta charset="utf-8" />
<title>IS</title>
<script src="script.js"></script>
<link rel="stylesheet" type="text/css" href="style.css" >
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
</head>
<?php
    require "script.php";
    $db = auth($_COOKIE["login"], $_COOKIE["password"]);
    $query = "select * from servis";
    $result = pg_query($db, $query);
    $result = pg_fetch_all($result);
?>
<body>
<h1>Справка о сервисе</h1>
<p><button class="btn btn-primary" onclick="document.location.replace('employees.php')">Назад</button></p>
<?php
    $servis = null;
    $i = 0;
    $mark = TRUE;
    while ($mark) {
        for ($j = 0; $j < count($result); $j++) {
            if ($result[$j]["id"] == $_REQUEST["id"]) {
                $servis = $result[$j]["note"];
                $mark = FALSE;
            }
        }
        $i++;
        if ($i >= 1000000) $mark = FALSE;
    }
    if ($servis != null) {
        echo "<h3 style=\"margin: 20px; font-family: SansSerif; font-size: 20pt\"><i>" . $servis . "</i></h3>";
    }
?>
</body>
</html>
