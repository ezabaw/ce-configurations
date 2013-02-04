<?php session_start();?>
<link type="text/css" href="css/onprem.css" rel="Stylesheet" />
<script type="text/javascript" src="js/jquery.min.js"></script>
<html>
<head>
</head>
<?php
$script_name=basename(__FILE__);
require_once(dirname($script_name).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_user']) || !$_SESSION['asper_user']){
    require_once(dirname($script_name).DIRECTORY_SEPARATOR.'validate_session.inc');
}
$db=new SQLite3($dbfile,SQLITE3_OPEN_READWRITE) or die("Unable to connect to database $dbfile");
if (isset($_GET["id"])&& is_numeric ($_GET['id'])){
    $id = $_GET["id"];
    $result=$db->query('select * from log where customer_id='.$id);
    $header='Actions log';
}elseif(!isset($_GET["edit"])){
    die('You need to pass a customer ID from customers.id.');
}

echo '
    <title>'.$header.'</title>
<body class=onprem>
<input type="hidden" id="customer_id" name="customer_id" value="'.$id.'" />
<h3><a href=#customer>Actions log:</a></h3>
<table id="logs" class=onprem>';
$index=0;
while($log_entries = $result->fetchArray(SQLITE3_ASSOC)){
    foreach($log_entries as $key => $val){
	if ($index%2){
	    $color='green';
	}else{
	    $color='yellow';
	}
	// no point in displaying customer ID.
	if ($key !== 'id' && $key !== 'customer_id'){
		echo "<tr class=$color><td>$key:</td><td><input type=text id='$key' class=k-textbox value='$val'></td></tr>";
	}
	$index++;
    }
	echo '<tr class=separator><td></td><td></td></tr>';
	echo '<tr class=separator><td></td><td></td></tr>';
}
    echo '</table></body></html>';
?>
