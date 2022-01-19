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
    if (isset($_REQUEST["exes"])) {
        $query = "select * from form_brigada_1(" . explode(".", $_REQUEST["id_zayvki"])[0] . "," . explode(".", $_REQUEST["snames"])[0] . "," . explode(".", $_REQUEST["exes"])[0] . ")";
        $result = pg_query($db, $query);
        $result = pg_fetch_all($result);
    }
    if (isset($_REQUEST["id"]) && isset($_REQUEST["state"])) {
        $query = "select * from proveril(" . $_REQUEST["id"] . ")";
        $result = pg_query($db, $query);
        $result = pg_fetch_all($result);
    }    
    $query = "select * from jurnal_zayavok_nach_sluj_1()";
    $result = pg_query($db, $query);
    $result = pg_fetch_all($result);
?>
<body>
<h1>Журнал заявок</h1>
<p><button class="btn btn-primary" onclick="document.location.replace('auth.php')">Назад</button></p>
<h2>Фильтр заявок</h2>
<button class="btn btn-primary" onclick="show_only_done()">Выполненные заявки</button>
<button class="btn btn-primary" onclick="show_all()">Все заявки</button>
<script>
    function show_all() {
        let table = document.getElementById("for_brigadir");
        table = table.getElementsByTagName("tbody")[0];
        table = table.children;
        for (let i = 1; i < table.length; i++) {
            table[i].style.display = "";
        }
    }
    function show_only_done() {
        show_all();
        let table = document.getElementById("for_brigadir");
        table = table.getElementsByTagName("tbody")[0];
        table = table.children;
        for (let i = 1; i < table.length; i++) {
            let tr = table[i];
            if (tr.childNodes[4].innerText != "Выполнена") {
                tr.style.display = "none";
            }
        }
    }
</script>
<p></p>
<form name="create_brigada" action="create_brigada.php" action="get">
    <input type="submit" class="btn btn-primary" value="Сформировать бригаду" onclick="handler(document.forms.create_brigada, 1)" />
</form>
<p></p>
<form name="proveril" action="jz_nachalnik_brigady.php" method="post">
    <input type="submit" class="btn btn-success" value="Проверил" onclick="handler(form, 5)"/>
</form>
<p></p>
<table id="for_brigadir" class="table" border="1">
<tr>
    <th>№ заявки</th>
    <th>Станок</th>
    <th>Проблемный узел</th>
    <th>Вид заявки</th>
    <th>Статус</th>
    <th>Бригада</th>
    <th>Дата поступления</th>
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
        if($row['idbrigada'] != "0") echo "<td>" . $row['idbrigada'] . "</td>";
        else echo "<td></td>";
        echo "<td>" . $row['date_postuplenya'] . "</td>";
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
        x.setAttribute("name", "state");
        x.setAttribute("value", id);
        form.appendChild(x);
    }
    let form = document.forms.proveril;
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
