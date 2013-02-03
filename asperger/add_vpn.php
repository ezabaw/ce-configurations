<?php
require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'conn.inc');
session_start();
if (!isset($_SESSION['asper_user']) || !$_SESSION['asper_user']){
    require_once(dirname($script_name).DIRECTORY_SEPARATOR.'validate_session.inc');
}
if (empty($_POST['gateway'])){
    die('ERR: A gateway is mandatory.');
}
$customer_id=SQLite3::escapeString($_POST['customer_id']);
$username=SQLite3::escapeString($_POST['username']);
$passwd=SQLite3::escapeString($_POST['passwd']);
$display_name=SQLite3::escapeString($_POST['display_name']);
$gateway=SQLite3::escapeString($_POST['gateway']);
$vpn_type=SQLite3::escapeString($_POST['type']);
$notes=SQLite3::escapeString($_POST['notes']);
$db=new SQLite3($dbfile) or die("Unable to connect to database $dbfile");
$query="insert into vpn values(NULL,$customer_id,'$username','$passwd','$display_name','$gateway','$vpn_type','$notes')";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode('ERROR: #' . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}else{
    $msg="Record for $display_name added successfully to vpn table.";
}
$db->close();
echo $msg;
?>
