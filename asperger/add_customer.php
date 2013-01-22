<?php
session_start();
require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_session']) || !$_SESSION['asper_session']){
    require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'validate_session.inc');
}
if (empty($_POST['name']) || empty($_POST['customer_tech_contact'])){
    die('A customer name and tech contact are mandatory.');
}
$name=SQLite3::escapeString($_POST['name']);
$customer_tech_contact=SQLite3::escapeString($_POST['customer_tech_contact']);
$pm=SQLite3::escapeString($_POST['pm']);
$am=SQLite3::escapeString($_POST['am']);
$ps_tech_contact=SQLite3::escapeString($_POST['ps_tech_contact']);
$on_prem_version=SQLite3::escapeString($_POST['on_prem_version']);
$notes=SQLite3::escapeString($_POST['notes']);
$db=new SQLite3($dbfile) or die("Unable to connect to database $dbfile");
$query="insert into customers values(NULL,'$name','$customer_tech_contact','$pm','$am','$ps_tech_contact','$on_prem_version',NULL,'$notes')";
$db->exec($query);
if ($db->lastErrorCode()){
    $msg=json_encode('ERROR: #' . $db->lastErrorCode() . ' '.$db->lastErrorMsg().' :(');
}else{
    $msg="Record for $name added successfully to customers.";
    $customer_asset_dir='assets/'.str_replace(' ','_',$name);
    if (!is_dir($customer_asset_dir)){
    	mkdir ($customer_asset_dir);
    }
}
$db->close();
echo $msg;
?>
