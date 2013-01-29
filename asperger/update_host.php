<?php
//var_dump($_POST);
session_start();
if (empty($_POST['host']) || empty($_POST['customer_id'])){
    die('A hostname and customer ID are mandatory.');
}
require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_session']) || !$_SESSION['asper_session']){
    require_once(dirname($script_name).DIRECTORY_SEPARATOR.'validate_session.inc');
}
$orig_host=$_POST['orig_host'];
$host=$_POST['host'];
$host_desc=SQLite3::escapeString($_POST['host_description']);
$dist_arch=SQLite3::escapeString($_POST['distro_version_arch']);
$ssh_user=SQLite3::escapeString($_POST['ssh_user']);
$ssh_passwd=SQLite3::escapeString($_POST['ssh_passwd']);
$notes=SQLite3::escapeString($_POST['notes']);
$customer_id=SQLite3::escapeString($_POST['customer_id']);
$db=new SQLite3($dbfile) or die("Unable to connect to database $dbfile");
$query="update hosts set hostname='$host' where customer_id=$customer_id and hostname='$orig_host'";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode("ERROR: on host update: '.$host .'\n#" . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}
$query="update hosts set host_description='$host_desc' where customer_id=$customer_id and hostname='$host'";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode("ERROR: on description update: $host_desc\n#" . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}
$query="update hosts set distro_version_arch='$dist_arch' where customer_id=$customer_id and hostname='$host'";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode("ERROR: distro and ver update $dist_arch\n#" . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}
$query="update hosts set ssh_user='$ssh_user' where customer_id=$customer_id and hostname='$host'";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode("ERROR: on SSH user: $ssh_user\n#" . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}
$query="update hosts set ssh_passwd='$ssh_passwd' where customer_id=$customer_id and hostname='$host'";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode('ERROR: ssh_passwd#' . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}
$query="update hosts set notes='$notes' where customer_id=$customer_id and hostname='$host' ";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode('ERROR: notes#' . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}
if (!isset($msg)){
    $msg="Record for $host updated successfully to hosts.";
}

$db->close();
echo $msg;
?>
