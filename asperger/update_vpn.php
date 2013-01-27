<?php
//var_dump($_POST);
session_start();
if (empty($_POST['gateway']) || empty($_POST['display_name'])){
    die('A gateway and display_name are mandatory.');
}
require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_session']) || !$_SESSION['asper_session']){
    require_once(dirname($script_name).DIRECTORY_SEPARATOR.'validate_session.inc');
}
$gateway=SQLite3::escapeString($_POST['gateway']);
$username=SQLite3::escapeString($_POST['username']);
$passwd=SQLite3::escapeString($_POST['passwd']);
$display_name=SQLite3::escapeString($_POST['display_name']);
$vpn_type=SQLite3::escapeString($_POST['type']);
$notes=SQLite3::escapeString($_POST['notes']);
$customer_id=SQLite3::escapeString($_POST['customer_id']);
$db=new SQLite3($dbfile) or die("Unable to connect to database $dbfile");
$query="update vpn set gateway='$gateway',username='$username',passwd='$passwd',display_name='$display_name',vpn_type='$vpn_type',notes='$notes' where customer_id=$customer_id";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode("ERROR: on vpn update: '.$gateway .'\n#" . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}
if (!isset($msg)){
    $msg="Record for $gateway updated successfully.";
}

$db->close();
echo $msg;
?>
