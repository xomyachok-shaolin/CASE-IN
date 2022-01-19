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
    if (isset($_REQUEST["machines"])) {
        $query = "select * from insert_zayavka(" . explode(".", $_REQUEST["machines"])[0] . ")";
        $result = pg_query($db, $query);
        $result = pg_fetch_all($result);
    }
    $query = "select * from jurnal_zayavok()";
    $result = pg_query($db, $query);
    $result = pg_fetch_all($result);
?>
<body>
<h1>Журнал заявок</h1>
<p><button class="btn btn-primary" onclick="document.location.replace('auth.php')">Назад</button></p>
<h2>Фильтр заявок</h2>
<button class="btn btn-primary" onclick="show_only_srochnye()">Срочная заявка</button>
<button class="btn btn-primary" onclick="show_only_planovye()">Плановая заявка</button>
<button class="btn btn-primary" onclick="unhide_all()">Все заявки</button>
<p></p>
<a class="btn btn-info" href="create_zayavka.php">Сформировать заявку</a>
<button class="btn">Сформировать отчет</button>
<p></p>
<table id="table-nach-uch" class="table" border="1">
<tr>
    <th>№</th>
    <th>Станок</th>
    <th>Проблемный узел</th>
    <th>Вид заявки</th>
    <th>Статус</th>
    <th>Дата поступления</th>
    <th>Дата выполнения</th>
</tr>
<?php
    if (is_array($result)) { 
    for ($i = 0; $i < count($result); $i++) {
        $row = $result[$i];
        echo "<tr>";
        echo "<td>" . $row['id'] . "</td>";
        echo "<td>" . $row['model'] . "</td>";
        echo "<td>" . $row['nameuzel'] . "</td>";
        echo "<td>" . $row['namevid'] . "</td>";
        if ($row['state'] == "1") echo "<td>Рассматривается</td>";
        if ($row['state'] == "2") echo "<td>Ожидает выполнения</td>";
        if ($row['state'] == "3") echo "<td>Выполняется</td>";
        if ($row['state'] == "4") echo "<td>Выполнена</td>";
        if ($row['state'] == "5") echo "<td>Утверждена</td>";
        echo "<td>" . $row['date_postuplenya'] . "</td>";
        echo "<td>" . $row['date_ispolnenya'] . "</td>";
        echo "</tr>";
    }
    }
?>
</table>
</body>
</html>
