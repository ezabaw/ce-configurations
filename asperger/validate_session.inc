<link type="text/css" href="css/onprem.css" rel="Stylesheet" />
<script type="text/javascript" src="js/jquery.min.js"></script>
<html>
<body class=onprem>
<head>
</head>
<?php
echo'
    <title>Login to Asperger</title>
<form method=post action=login.php>
    <fieldset class=login>
	<legend>Login</legend>
	<ul>
	    <li class="fl">
		<label for="username">Username:</label>
		<input type="text" id="username" name="username" autocomplete="on">
	    </li>
	    <li class="fl">
		<label for="passwd">Password:</label>
		<input type="password" id="passwd" name="passwd" autocomplete="on">
	    </li>
	    <li class="fl"> <input type=submit value="login"></li>
	</ul>
    </fieldset>
</form>
';
exit (1);
?>
</body>
</html>
