function show_only_srochnye() {
    unhide_all();
    let table = document.getElementById("table-nach-uch");
    table = table.getElementsByTagName("tbody")[0];
    table = table.children;
    for (let i = 1; i < table.length; i++) {
        let tr = table[i];
        if (tr.childNodes[3].innerText != "Срочная") {
            tr.style.display = "none";
        }
    }
}

function show_only_planovye() {
    unhide_all();
    let table = document.getElementById("table-nach-uch");
    table = table.getElementsByTagName("tbody")[0];
    table = table.children;
    for (let i = 1; i < table.length; i++) {
        let tr = table[i];
        if (tr.childNodes[3].innerText != "Плановая") {
            tr.style.display = "none";
        }
    }
}

function unhide_all() {
    let table = document.getElementById("table-nach-uch");
    table = table.getElementsByTagName("tbody")[0];
    table = table.children;
    for (let i = 1; i < table.length; i++) {
        table[i].style.display = "";
    }
}