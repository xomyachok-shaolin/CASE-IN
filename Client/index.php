<?php 
    require "script.php";
    if (isset($_REQUEST["logout"])) {
        nulify_cookie();
    }
?>
<html>
<head>
<title>IS</title>
<script src="script.js"></script>
<link rel="stylesheet" type="text/css" href="style.css" >
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
</head>
<body>
<?php if(isset($_COOKIE["login"]) == FALSE): ?>
<form style="margin-left:50px" class="form-horizontal" action="auth.php" method="post">
  <div class="control-group">
    <label class="control-label" for="login">Логин</label>
    <div class="controls">
      <input type="text" id="login" name="login" placeholder="Логин" required>
    </div>
  </div>
  <div class="control-group">
    <label class="control-label" for="password">Пароль</label>
    <div class="controls">
      <input type="password" name="password" id="password" placeholder="Пароль" required>
    </div>
  </div>
  <div class="control-group">
    <div class="controls">
       <label style="margin-left: 20px" class="checkbox">
          <input type="checkbox" name="remembered" checked/>Запомнить
       </label>
       <p></p>
      <button type="submit" class="btn">Войти</button>
    </div>
  </div>
</form>
<?php else: ?>
<script>
    document.location.replace("auth.php");
</script>
<?php endif; ?>
</body>
</html>