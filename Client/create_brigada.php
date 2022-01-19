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
?>
<body>
<h1>Формирование бригады</h1>
<form action="jz_nachalnik_brigady.php" method="get">
<div class="sz1">
<p><i>Укажите типы сервиса:</i></p>
<select style="width:400px" size="20" name="snames">
  <?php 
    $query = "select * from servis";
    $result = pg_query($db, $query);
    $result = pg_fetch_all($result);
    for ($i = 0; $i < count($result); $i++) {
        echo "<option>" . $result[$i]["id"] . "." . $result[$i]["name"] . "</option>";
    }
  ?>
</select>
<p></p>
</div>
<div class="sz2">
<p><i>Укажите исполнителей сервиса:</i></p>
<select style="width:400px" size="20" name="exes">
  <?php 
    $query = "select * from function()";
    $result = pg_query($db, $query);
    $result = pg_fetch_all($result);
    for ($i = 0; $i < count($result); $i++) {
        echo "<option>" . $result[$i]["id"] . "." . $result[$i]["first_name"] . " " . $result[$i]["second_name"] . " " . $result[$i]["otchestvo"] . "</option>";
    }
  ?>
</select>
<p></p>
</div>
<div class="clearfix"></div>
<input type="hidden" name="id_zayvki" value="<?= $_REQUEST["id"] ?>"
<p></p>
<input style="float: right; margin-right: 250px" type="submit" class="btn btn-success" value="Сформировать" />
</form>
<button style="float:left; margin-left: 250px;" class="btn btn-primary" onclick="document.location.replace('jz_nachalnik_brigady.php')">Назад</button>
</body>
</html>
