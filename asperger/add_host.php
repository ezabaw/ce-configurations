<?php
session_start();
if (empty($_POST['host']) || empty($_POST['customer_id'])){
    die('ERR: A hostname and customer ID are mandatory.');
}
require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_user']) || !$_SESSION['asper_user']){
    require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'validate_session.inc');
}
$sys_user=$_SESSION['asper_user'];
$host=$_POST['host'];
$host_desc=SQLite3::escapeString($_POST['host_description']);
$dist_arch=SQLite3::escapeString($_POST['distro_version_arch']);
$ssh_user=SQLite3::escapeString($_POST['ssh_user']);
$ssh_passwd=SQLite3::escapeString($_POST['ssh_passwd']);
$notes=SQLite3::escapeString($_POST['notes']);
$customer_id=SQLite3::escapeString($_POST['customer_id']);
$db=new SQLite3($dbfile) or die("Unable to connect to database $dbfile");
$query="insert into hosts values(NULL,$customer_id,'$host','$host_desc','$dist_arch','$ssh_user','$ssh_passwd','$notes')";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode('ERROR: #' . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}else{
 	$query="insert into log values(NULL,'Added host $host.',DATE(),'$sys_user','$customer_id')";
	$db->exec($query);
	$msg="Record for $host added successfully to hosts.";
}
$db->close();
echo $msg;
?>
