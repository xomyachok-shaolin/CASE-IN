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
    if (isset($_REQUEST["id"]) && isset($_REQUEST["priority"])) {
        $query = "select * from upd_prior(" . $_REQUEST["id"] . "," . $_REQUEST["priority"] . ")";
        $result = pg_query($db, $query);
        $result = pg_fetch_all($result);
    }    
    $query = "select * from func_jurnal_obslujivaniya_2()";
    $result = pg_query($db, $query);
    $result = pg_fetch_all($result);
?>
<body>
<h1>Журнал обслуживания</h1>
<p><button class="btn btn-primary" onclick="document.location.replace('auth.php')">Назад</button></p>
<h2>Фильтр (Виды заявок)</h2>
<button class="btn btn-primary" onclick="show_only_srochnye()">Срочные</button>
<button class="btn btn-primary" onclick="show_only_planovye()">Плановые</button>
<button class="btn btn-primary" onclick="unhide_all()">Все</button>
<h2>Установить приоритет</h2>
<form name="low" action="boss.php" method="post">
    <input type="submit" class="btn btn-success" onclick="handler(form_1, 1)" value="Низкий" />
</form>
<form name="mid" action="boss.php" method="post">
    <input type="submit" class="btn btn-warning" onclick="handler(form_2, 2)" value="Средний" />
</form>
<form name="high" action="boss.php" method="post">
    <input type="submit" class="btn btn-danger" onclick="handler(form_3, 3)" value="Высокий" />
</form>
<p></p>
<table id="table-nach-uch" class="table" border="1">
<tr>
    <th>№ заявки</th>
    <th>№ исполняем. бригады</th>
    <th>Дата поступления</th>
    <th>Вид заявки выполнения</th>
    <th>Приоритет</th>
    <th>Станок/компонент</th>
    <th>Проблемный узел</th>
</tr>
<?php
    if (is_array($result)) { 
    for ($i = 0; $i < count($result); $i++) {
        $row = $result[$i];
        echo "<tr>";
        echo "<td>" . $row['id_zayavki'] . "</td>";
        echo "<td>" . $row['id_brigady'] . "</td>";
        echo "<td>" . $row['date_postuplenya'] . "</td>";
        echo "<td>" . $row['vidzayavki'] . "</td>";
        if ($row['prioritet'] == "1") echo "<td>Низкий</td>";
        if ($row['prioritet'] == "2") echo "<td>Средний</td>";
        if ($row['prioritet'] == "3") echo "<td>Высокий</td>";
        echo "<td>" . $row['model'] . "</td>";
        echo "<td>" . $row['nameuzel'] . "</td>";
        echo "</tr>";
    }
    }
?>
</table>
<script>
    function handler(form, id) {
        if (chosenRow == null) return;
        let x = document.createElement("input");
        x.setAttribute("type", "hidden");
        x.setAttribute("name", "id");
        x.setAttribute("value", chosenRow.children[0].innerText);
        form.appendChild(x);
        x = document.createElement("input");
        x.setAttribute("type", "hidden");
        x.setAttribute("name", "priority");
        x.setAttribute("value", id);
        form.appendChild(x);
    }
    let form_1 = document.forms.low;
    let form_2 = document.forms.mid;
    let form_3 = document.forms.high;
    let chosenRow = null;
    let rows = document.getElementsByTagName("table")[0].getElementsByTagName("tbody")[0].children;
    for (let i = 1; i < rows.length; i++) {
        let row = rows[i];
        row.addEventListener("click", (event) => {
            if (chosenRow == null) {
                chosenRow = event.target.parentNode;
                chosenRow.style.backgroundColor = "black";
                chosenRow.style.color = "white";
            } else if (chosenRow == event.target.parentNode) {
                chosenRow.style.backgroundColor = "white";
                chosenRow.style.color = "black";
                chosenRow = null;                
            } else {
                chosenRow.style.backgroundColor = "white";
                chosenRow.style.color = "black";
                chosenRow = event.target.parentNode;
                chosenRow.style.backgroundColor = "black";
                chosenRow.style.color = "white";
            }
        });
    }
</script>
</body>
</html>
