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
    $query = "select * from all_machin()";
    $result = pg_query($db, $query);
    $result = pg_fetch_all($result);
?>
<body>
<h1>Формирование заявки</h1>
<form style="margin-left:150px" action="jz_nachalnik_uchastka.php" method="get">
<p><i>Выберите станок:</i></p>
<select style="width:150px" name="machines">
<?php
    for ($i = 0; $i < count($result); $i++) {
        echo "<option>" . $result[$i]["id"] . "." . $result[$i]["model"] . "</option>";
    }
?>
</select>
<p></p>
<input class="btn btn-primary" type="submit" value="Сформировать" />
</form>
</body>
</html>
