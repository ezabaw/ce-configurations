<?php
//var_dump($_POST);
session_start();
if (empty($_POST['name'])){
    die('A client name is required.');
}
require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_user']) || !$_SESSION['asper_user']){
    require_once(dirname($script_name).DIRECTORY_SEPARATOR.'validate_session.inc');
}
$client_id=SQLite3::escapeString($_POST['client_id']);
$name=SQLite3::escapeString($_POST['name']);
$tech_contact=SQLite3::escapeString($_POST['tech_contact']);
$client_pm=SQLite3::escapeString($_POST['client_pm']);
$client_am=SQLite3::escapeString($_POST['client_am']);
$engineer=SQLite3::escapeString($_POST['engineer']);
$version=SQLite3::escapeString($_POST['version']);
$sharepoint=SQLite3::escapeString($_POST['sharepoint']);
$notes=SQLite3::escapeString($_POST['notes']);

$db=new SQLite3($dbfile) or die("Unable to connect to database $dbfile");
$query="update customers set name='$name',customer_tech_contact='$tech_contact',pm='$client_pm',am='$client_am',ps_tech_contact='$engineer',on_prem_version='$version',sharepoint='$sharepoint',notes='$notes' where id=$client_id";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode("ERROR: on client update: " . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}
if (!isset($msg)){
    $msg="Client $name updated successfully.";
}

$db->close();
echo $msg;
?>
