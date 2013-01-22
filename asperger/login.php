<?php
require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'conn.inc');
// using ldap bind
$ldap_user  = $_POST['username'];     // ldap rdn or dn
$ldap_pass = $_POST['passwd'];  // associated password
if ($ldap_user && $ldap_pass){
	
	// connect to ldap server
	$ldapconn = ldap_connect($ldap_server) or die("Failed to conect to auth server.\n");
	if ($ldapconn) {

	    // binding to ldap server
	    $ldapbind = @ldap_bind($ldapconn, $realm.'\\'.$ldap_user, $ldap_pass);
	    // supress output is the most disturbing-root-of-all-evil operator, however, if binding fail, and it prints the message to STDOUT, that is the browser, it will refuse to do the header call. In production, the display_errors should be set to off so it won't output to browser but..

	    // verify binding
	    if ($ldapbind) {
		session_start();
		$_SESSION['asper_session']=true;
	    }
	    header('Location: index.php');

	}
}else{
	header('Location: index.php');
}
?>
