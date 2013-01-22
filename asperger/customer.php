<?php session_start();?>
<link type="text/css" href="css/onprem.css" rel="Stylesheet" />
<script type="text/javascript" src="js/jquery.min.js"></script>
<html>
<head>
</head>
<script type="text/javascript">
function unhide(divID) 
{
    var item = document.getElementById(divID);
    if (item) {
	item.className=(item.className==='hidden')?'unhidden':'hidden';
    }
}
function unhide_add(divID)
{
    var item = document.getElementById(divID);
    item.className='unhidden';
    new_host.focus();
}

function show_passwd(obj)
{
	//var item=document.getElementById(id);
	//item.innerHTML = "<input id="+id+" type=text class=k-textbox>";
	var newO=document.createElement('input');
	newO.setAttribute('type','text');
	newO.setAttribute('id',obj.getAttribute('id'));
	obj.parentNode.replaceChild(newO,obj);
	newO.focus();
}
function update_host1(host_id)
{
    var orig_host=host_id;
    var host = document.getElementById(host_id+'_hostname').value;
    var host_description = document.getElementById(host_id+'_host_description').value;
    var distro_version_arch = document.getElementById(host_id+'_distro_version_arch').value;
    var ssh_user = document.getElementById(host_id+'_ssh_user').value;
    var ssh_passwd = document.getElementById(host_id+'_ssh_passwd').value;
    var notes = document.getElementById(host_id+'_notes').value;
    var cust_id = document.getElementById('customer_id').value;
    $.ajax({
		  type: 'POST',
		  url: 'update_host.php',
		  data: {'customer_id': cust_id,'orig_host': orig_host, 'host': host,'host_description': host_description,'distro_version_arch': distro_version_arch, 'ssh_user': ssh_user, 'ssh_passwd': ssh_passwd, 'notes': notes},
		  success: function(data){
		      if (data!==null){
			    alert(data);
		      } 
		  }
    });
}
function add_host()
{
    var host = document.getElementById('new_host').value;
    var host_description = document.getElementById('new_host_description').value;
    var distro_version_arch = document.getElementById('new_distro_version_arch').value;
    var ssh_user = document.getElementById('new_ssh_user').value;
    var ssh_passwd = document.getElementById('new_ssh_passwd').value;
    var notes = document.getElementById('new_notes').value;
    var cust_id = document.getElementById('customer_id').value;
    $.ajax({
		  type: 'POST',
		  url: 'add_host.php',
		  data: {'customer_id': cust_id, 'host': host,'host_description': host_description,'distro_version_arch': distro_version_arch, 'ssh_user': ssh_user, 'ssh_passwd': ssh_passwd, 'notes': notes},
		  success: function(data){
		      if (data!==null){
			    alert(data);
		      } 
		  }
    });
    add_form.className='hidden';
    //document.location.reload();
}
function add_vpn()
{
    var gateway = document.getElementById('vpn_gateway').value;
    var username = document.getElementById('vpn_user').value;
    var passwd = document.getElementById('vpn_passwd').value;
    var display_name = document.getElementById('vpn_display_name').value;
    var type = document.getElementById('vpn_type').value;
    var notes = document.getElementById('vpn_notes').value;
    var cust_id = document.getElementById('customer_id').value;
    $.ajax({
		  type: 'POST',
		  url: 'add_vpn.php',
		  data: {'customer_id': cust_id, 'gateway': gateway,'username': username,'passwd': passwd, 'display_name': display_name, 'type': type, 'notes': notes},
		  success: function(data){
		      if (data!==null){
			    alert(data);
		      } 
		  }
    });
    add_vpn.className='hidden';
    //document.location.reload();
}
</script>
<?php
$script_name=basename(__FILE__);
require_once(dirname($script_name).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_session']) || !$_SESSION['asper_session']){
    require_once(dirname($script_name).DIRECTORY_SEPARATOR.'validate_session.inc');
}
$db=new SQLite3($dbfile,SQLITE3_OPEN_READWRITE) or die("Unable to connect to database $dbfile");
if (isset($_GET["id"])&& is_numeric ($_GET['id'])){
    $id = $_GET["id"];
    $result=$db->query('select * from customers where id='.$id);
    $header='Customer details:';
}elseif(!isset($_GET["edit"])){
    die('You need to pass a customer ID from customers.id.');
}

echo '
    <title>'.$header.'</title>
<body class=onprem>
<form action="'.$script_name.'" method="GET">';
echo '<table id="customers">';
$index=0;
while($customers = $result->fetchArray(SQLITE3_ASSOC)){
    foreach($customers as $key => $val){
	if ($index%2){
	    $color='green';
	}else{
	    $color='yellow';
	}
	echo "<tr class=$color><td>$key</td><td>$val</td></tr>";
	$index++;
    }
}
echo 
    '</table>
    <input type="hidden" id="customer_id" name="customer_id" value="'.$id.'" />
    <table id="hosts"><h3 class="onprem"><tr>';
$result=$db->query('select hostname from hosts where customer_id='.$id);
echo '<h3><a href=#hosts>Hosts:</a></h3>';
while($hosts = $result->fetchArray(SQLITE3_ASSOC)){
	$index++;
    foreach($hosts as $key => $val){
	$result1=$db->query('select hostname, host_description, distro_version_arch, ssh_user, ssh_passwd, notes from hosts where hostname="'.$val.'"');
	while($host = $result1->fetchArray(SQLITE3_ASSOC)){
	    $id1=str_replace('.','',$val);
	    echo '<div class=.k-slider id=hide_show_div><input type=button id=hide_show value="'.$val.'" onclick="javascript:unhide(\''.$id1.'\')"></div>
		<div id='.$id1.' class=hidden><ul id="navlist">';

	    echo '<li>Hostname: <input type=text class=k-textbox id="'.$id1.'_hostname" value="'.$host['hostname'].'"></il><br>';
	    echo '<li>Description: <input type=text class=k-textbox id="'.$id1.'_host_description" value="'.$host['host_description'].'"></il><br>';
	    echo '<li>Distro && arch: <input type=text class=k-textbox id="'.$id1.'_distro_version_arch" value="'.$host['distro_version_arch'].'"></il><br>';
	    echo '<li>User: <input type=text class=k-textbox id="'.$id1.'_ssh_user" value="'.$host['ssh_user'].'"></il><br>';
	    echo '<li>Passwd: <input type=password class=k-textbox id="'.$id1.'_ssh_passwd" value="'.$host['ssh_passwd'].'" onfocus=="javascript:show_passwd(this);></il><br>';
	    echo '<li>Notes: <textarea class=k-textbox id="'.$id1.'_notes" rows=3>'.$host['notes'].'</textarea><br>
	    <input type=button id="'.$id1.'_update_host" value="Update" onclick="javascript:update_host1(\''.$id1.'\')"><br>
	    </div><br>';
	}
    }
	
}
echo '<tr></table><div class=.k-slider ><input type=button class=.k-button id=hide_show value="Add new host" onclick="javascript:unhide_add(\'add_form\')"></div>
<div id=\'add_form\' class=hidden>
    <fieldset>
	<legend>Add host</legend>
	<ul>
	    <li class="fl">
		<label for="new_host">Host:</label>
		<input type="text" id="new_host" name="new_host" tabindex="10" autocomplete="on">
	    </li>

	    <li class="fl">
	    <label for="new_host_description">Description:</label>
		<input type="text" id="new_host_description" name="new_host_description" tabindex="20" autocomplete="on">
	    </li>

	    <li class="fl">
	    <label for="new_distro_version_arch">Distro and arch:</label>
		<input type="text" id="new_distro_version_arch" name="new_distro_version_arch" tabindex="30" autocomplete="on">
	    </li>

	    <li class="fl">
	    <label for="new_ssh_user">User:</label>
		<input type="text" id="new_ssh_user" name="new_ssh_user" tabindex="40" autocomplete="on">
	    </li>
	    <li class="fl">
	    <label for="new_ssh_passwd">Passwd:</label>
		<input type="password" id="new_ssh_passwd" name="new_ssh_passwd" tabindex="50" autocomplete="on">
	    </li>
	    <li class="fl">
	    <label for="new_notes">Notes:</label>
		<input type="text" id="new_notes" name="new_notes" tabindex="60" autocomplete="on">
	    </li>
	    <li class="fl">
		<label for="update"></label>
		<input type=button value="update" onclick="javascript:add_host();">
	    </li>

	    </ul>
    </fieldset></div>
<table id="vpn">


<h3 class="onprem"><tr>';
$result=$db->query('select gateway from vpn where customer_id='.$id);
echo '<h3><a href="#vpn">VPN:</a></h3>';
while($vpns = $result->fetchArray(SQLITE3_ASSOC)){
	$index++;
    foreach($vpns as $key => $val){
	error_log('select username,passwd,display_name,gateway,vpn_type from vpn where gateway='.$val."\n",3,'/tmp/tmp');
	$result1=$db->query('select username,passwd,display_name,gateway,vpn_type,notes from vpn where gateway=\''.$val.'\'');
	while($vpn = $result1->fetchArray(SQLITE3_ASSOC)){
	    $id1=str_replace('.','',$val);
	    $id1=str_replace(' ','',$val);
	    echo '<div class=.k-slider id=hide_show_div><input type=button id=hide_show_vpn value="'.$val.'" onclick="javascript:unhide(\''.$id1.'\')"></div>
		<div id='.$id1.' class=hidden><ul id="navlist">';

	    echo '<li>Description: <input type=text class=k-textbox id="'.$id1.'_display_name" value="'.$vpn['display_name'].'"></il><br>';
	    echo '<li>Gateway: <input type=text class=k-textbox id="'.$id1.'_gateway" value="'.$vpn['gateway'].'"></il><br>';
	    echo '<li>User: <input type=text class=k-textbox id="'.$id1.'_username" value="'.$vpn['username'].'"></il><br>';
	    echo '<li>Passwd: <input type=password class=k-textbox id="'.$id1.'_passwd" value="'.$vpn['passwd'].'"></il><br>';
	    echo '<li>Notes: <textarea class=k-textbox id="'.$id1.'_notes" rows=3>'.$vpn['notes'].'</textarea><br>';
	    echo '</div><br>';
	}
    }
	
}
    echo'<form method="POST">
    <div class=.k-slider ><input type=button class=.k-button id=hide_show_vpn value="Add VPN creds" onclick="javascript:unhide(\'add_vpn\')"></div>
<div id=\'add_vpn\' class=hidden>
    <fieldset>
	<legend>VPN</legend>
	<ul>
	    <li class="fl">
	    <label for="vpn_display_name">VPN display name:</label>
		<input type="text" id="vpn_display_name" name="vpn_display_name" tabindex="5" autocomplete="on">
	    </li>

	    <li class="fl">
		<label for="vpn_gateway">Gateway:</label>
		<input type="text" id="vpn_gateway" name="vpn_gateway" tabindex="10" autocomplete="on">
	    </li>

	    <li class="fl">
	    <label for="vpn_user">User:</label>
		<input type="text" id="vpn_user" name="vpn_user" tabindex="20" autocomplete="on">
	    </li>

	    <li class="fl">
	    <label for="vpn_passwd">Passwd:</label>
		<input type="text" id="vpn_passwd" name="vpn_passwd" tabindex="30" autocomplete="on">
	    </li>

	    <li class="fl">
	    <label for="vpn_type">VPN type:</label>
		<input type="text" id="vpn_type" name="vpn_type" tabindex="40" autocomplete="on">
	    </li>

	    <li class="fl">
	    <label for="vpn_notes">Notes:</label>
		<input type="text" id="vpn_notes" name="new_notes" tabindex="50" autocomplete="on">
	    </li>
	    <li class="fl">
		<label for="update"></label>
		<input type=button value="update" onclick="javascript:add_vpn();">
	    </li>

	    </ul>
    </fieldset></div>
    </form>
    <body>
    </html>';
?>
