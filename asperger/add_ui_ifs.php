<?php
session_start();
if (empty($_POST['admin_console_url']) && empty($_POST['kmc_url'])&& empty($_POST['kms_url'])){
    die('At least one URL is mandatory.');
}
require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_user']) || !$_SESSION['asper_user']){
    require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'validate_session.inc');
}

$env=$_POST['env'];
$admin_console_url=$_POST['admin_console_url'];
$admin_console_user=SQLite3::escapeString($_POST['admin_console_user']);
$admin_console_passwd=SQLite3::escapeString($_POST['admin_console_passwd']);
$kmc_url=SQLite3::escapeString($_POST['kmc_url']);
$kmc_user=SQLite3::escapeString($_POST['kmc_user']);
$kmc_passwd=SQLite3::escapeString($_POST['kmc_passwd']);
$kms_admin_url=SQLite3::escapeString($_POST['kms_admin_url']);
$kms_admin_user=SQLite3::escapeString($_POST['kms_admin_user']);
$kms_admin_passwd=SQLite3::escapeString($_POST['kms_admin_passwd']);
$notes=SQLite3::escapeString($_POST['notes']);
$customer_id=SQLite3::escapeString($_POST['customer_id']);
$db=new SQLite3($dbfile) or die("Unable to connect to database $dbfile");
$query="insert into ui values(NULL,$customer_id,'$admin_console_url','$admin_console_user','$admin_console_passwd','$kmc_url','$kmc_user','$kmc_passwd','$kms_admin_url','$kms_admin_user','$kms_admin_passwd','$notes','$env')";
error_log($query."\n",3,'/tmp/que');
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode('ERROR: #' . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}else{
    $msg="Record added successfully to ui.";
}
$db->close();
echo $msg;
?>
