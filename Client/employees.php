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
    if (isset($_REQUEST["id"]) && isset($_REQUEST["state"])) {
        $query = "select * from upd_state(" . $_REQUEST["id"] . "," . $_REQUEST["state"] . ")";
        $result = pg_query($db, $query);
        $result = pg_fetch_all($result);
    }    
    $query = "select * from jurnal_plans_4()";
    $result = pg_query($db, $query);
    $result = pg_fetch_all($result);
?>
<body>
<h1>План работы</h1>
<p><button class="btn btn-primary" onclick="document.location.replace('auth.php')">Назад</button></p>
<table class="table" border="1">
<tr>
    <th>№</th>
    <th>Станок</th>
    <th>Узел</th>
    <th>Статус</th>
    <th>Приоритет</th>
</tr>
<?php
    if (is_array($result)) { 
    for ($i = 0; $i < count($result); $i++) {
        $row = $result[$i];
        echo "<tr>";
        echo "<td>" . $row['id'] . "</td>";
        echo "<td>" . $row['model'] . "</td>";
        echo "<td>" . $row['nameuzel'] . "</td>";
        if ($row['state'] == "1") echo "<td>Рассматривается</td>";
        if ($row['state'] == "2") echo "<td>Ожидает выполнения</td>";
        if ($row['state'] == "3") echo "<td>Выполняется</td>";
        if ($row['state'] == "4") echo "<td>Выполнена</td>";
        if ($row['state'] == "5") echo "<td>Утверждена</td>";
        if ($row['prioritet'] == "1") echo "<td>Низкий</td>";
        if ($row['prioritet'] == "2") echo "<td>Средний</td>";
        if ($row['prioritet'] == "3") echo "<td>Высокий</td>";
        echo "</tr>";
    }
    }
?>
</table>
<h2>Тип сервиса</h2>
<table class="table" border="0">
<?php
    $query = "select id, name from servis";
    $result = pg_query($db, $query);
    $result = pg_fetch_all($result);
    #for ($i = 0; $i < count($result); $i++) {
        #echo "<tr>";
        #echo "<td>" . $result[$i]["id"] . "</td>";
        #echo "<td>" . $result[$i]["name"] . "</td>";
        #echo "</tr>";
    #}
    echo "<tr><td>1</td><td>Заменить масло</td></tr>";
?>
</table>
<script>
    let servisy = document.getElementsByTagName("table")[1].getElementsByTagName("tbody")[0].children;
    let chosenServis = null;
    for (let i = 0; i < servisy.length; i++) {
        let row = servisy[i];
        row.addEventListener("click", (event) => {
            if (chosenServis == null) {
                chosenServis = event.target.parentNode;
                chosenServis.style.backgroundColor = "black";
                chosenServis.style.color = "white";
            } else if (chosenServis == event.target.parentNode) {
                chosenServis.style.backgroundColor = "white";
                chosenServis.style.color = "black";
                chosenServis = null;                
            } else {
                chosenServis.style.backgroundColor = "white";
                chosenServis.style.color = "black";
                chosenServis = event.target.parentNode;
                chosenServis.style.backgroundColor = "black";
                chosenServis.style.color = "white";
            }
        });
    }
</script>
<form name="about" action="about.php" method="get">
    <input type="submit" class="btn btn-info" value="Справка по типу сервиса" onclick="add_hidden(document.forms.about)"/>
</form>
<script>
    function add_hidden(form) {
        if (chosenServis == null) return;
        let x = document.createElement("input");
        x.setAttribute("type", "hidden");
        x.setAttribute("name", "id");
        x.setAttribute("value", chosenServis.children[0].innerText);
        form.appendChild(x);
        x = document.createElement("input");
        x.setAttribute("type", "hidden");
        x.setAttribute("name", "title");
        x.setAttribute("value", chosenServis.children[1].innerText);
        form.appendChild(x);
    }
</script>
<form name="pristypitb" action="employees.php", method="post">
    <input type="submit" class="btn btn-primary" value="Приступить" onclick="handler(form_1, 3)"/>
</form>
<form name="ispolnitb" action="employees.php", method="post">
    <input type="submit" class="btn btn-success" value="Исполнить" onclick="handler(form_2, 4)"/>
</form>
</body>
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
    let form_1 = document.forms.pristypitb;
    let form_2 = document.forms.ispolnitb;
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
</html>
