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
	var newO=document.createElement('input');
	newO.setAttribute('type','text');
	newO.setAttribute('id',obj.getAttribute('id'));
	newO.setAttribute('value',obj.getAttribute('value'));
	obj.parentNode.replaceChild(newO,obj);

}
/*
function hide_passwd(obj)
{
	var newO=document.createElement('input');
	newO.setAttribute('type','password');
	newO.setAttribute('id',obj.getAttribute('id'));
	newO.setAttribute('value',obj.getAttribute('value'));
	newO.setAttribute('onfocus',"'javascript:show_passwd(newO)'");
	newO.parentNode.replaceChild(newO,obj);
}
*/
function update_host(orig_host,host_id)
{
    //var orig_host=host_id;
    var del_host=document.getElementById('del_host');
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
			message=document.getElementById("host_message_"+host_id);
			if (data.indexOf("ERR") !==-1) {
				message.style.color = 'red';
			}else{
				message.style.color = 'green';
			}
    			message.className='unhidden';
			message.innerHTML = data;
			message.style.fontWeight="bold";
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
			message=document.getElementById("new_host_message");
			if (data.indexOf("ERR") !==-1) {
				message.style.color = 'red';
			}else{
				message.style.color = 'green';
			}
    			message.className='unhidden';
			message.innerHTML = data;
			message.style.fontWeight="bold";
		      } 
		  }
    });
    add_form.className='hidden';
    //document.location.reload();
}


function add_ui_ifs()
{
    var env = document.getElementById('env').value;
    var admin_console_url = document.getElementById('admin_console_url').value;
    var admin_console_user = document.getElementById('admin_console_user').value;
    var admin_console_passwd = document.getElementById('admin_console_passwd').value;
    var kmc_url = document.getElementById('kmc_url').value;
    var kmc_user = document.getElementById('kmc_user').value;
    var kmc_passwd = document.getElementById('kmc_passwd').value;
    var kms_admin_url = document.getElementById('kms_url').value;
    var kms_admin_user = document.getElementById('kms_user').value;
    var kms_admin_passwd = document.getElementById('kms_passwd').value;
    var notes = document.getElementById('ui_ifs_notes').value;
    var cust_id = document.getElementById('customer_id').value;
    $.ajax({
		  type: 'POST',
		  url: 'add_ui_ifs.php',
		  data: {'customer_id': cust_id, 'env': env,'admin_console_url': admin_console_url,'admin_console_user': admin_console_user,'admin_console_passwd': admin_console_passwd, 'kmc_url': kmc_url, 'kmc_user': kmc_user, 'kmc_passwd': kmc_passwd,'kms_admin_url': kms_admin_url, 'kms_admin_user': kms_admin_user, 'kms_admin_passwd': kms_admin_passwd,'notes': notes},
		  success: function(data){
		      if (data!==null){
			message=document.getElementById("new_ui_message");
			if (data.indexOf("ERR") !==-1) {
				message.style.color = 'red';
			}else{
				message.style.color = 'green';
			}
    			message.className='unhidden';
			message.innerHTML = data;
			message.style.fontWeight="bold";
		      } 
		  }
    });
    add_form.className='hidden';
    //document.location.reload();
}
function update_ui_ifs(id)
{
    var envid = id; 
    var env = document.getElementById('env_'+id).value;
    var admin_console_url = document.getElementById(id+'_admin_console_url').value;
    var admin_console_user = document.getElementById(id+'_admin_console_user').value;
    var admin_console_passwd = document.getElementById(id+'_admin_console_passwd').value;
    var kmc_url = document.getElementById(id+'_kmc_url').value;
    var kmc_user = document.getElementById(id+'_kmc_user').value;
    var kmc_passwd = document.getElementById(id+'_kmc_passwd').value;
    var kms_admin_url = document.getElementById(id+'_kms_admin_url').value;
    var kms_admin_user = document.getElementById(id+'_kms_admin_user').value;
    var kms_admin_passwd = document.getElementById(id+'_kms_admin_passwd').value;
    var notes = document.getElementById(id+'_notes').value;
    var cust_id = document.getElementById('customer_id').value;
    $.ajax({
		  type: 'POST',
		  url: 'update_ui_ifs.php',
		  data: {'customer_id': cust_id, 'env': env,'admin_console_url': admin_console_url,'admin_console_user': admin_console_user,'admin_console_passwd': admin_console_passwd, 'kmc_url': kmc_url, 'kmc_user': kmc_user, 'kmc_passwd': kmc_passwd,'kms_admin_url': kms_admin_url, 'kms_admin_user': kms_admin_user, 'kms_admin_passwd': kms_admin_passwd,'notes': notes, 'envid':envid},
		  success: function(data){
		      if (data!==null){
			message=document.getElementById("ui_message_"+id);
			if (data.indexOf("ERR") !==-1) {
				message.style.color = 'red';
			}else{
				message.style.color = 'green';
			}
    			message.className='unhidden';
			message.innerHTML = data;
			message.style.fontWeight="bold";
		      } 
		  }
    });
    add_form.className='hidden';
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
			message=document.getElementById("new_vpn_message");
			if (data.indexOf("ERR") !==-1) {
				message.style.color = 'red';
			}else{
				message.style.color = 'green';
			}
    			message.className='unhidden';
			message.innerHTML = data;
			message.style.fontWeight="bold";
		      } 
		  }
    });
    add_vpn.className='hidden';
    //document.location.reload();
}
function update_vpn(id)
{
    var gateway = document.getElementById(id+'_gateway').value;
    var username = document.getElementById(id+'_username').value;
    var passwd = document.getElementById(id+'_passwd').value;
    var display_name = document.getElementById(id+'_display_name').value;
    var type = document.getElementById(id+'_type').value;
    var notes = document.getElementById(id+'_notes').value;
    var cust_id = document.getElementById('customer_id').value;
    $.ajax({
		  type: 'POST',
		  url: 'update_vpn.php',
		  data: {'customer_id': cust_id, 'gateway': gateway,'username': username,'passwd': passwd, 'display_name': display_name, 'type': type, 'notes': notes},
		  success: function(data){
		      if (data!==null){
			message=document.getElementById("vpn_message_"+id);
			if (data.indexOf("ERR") !==-1) {
				message.style.color = 'red';
			}else{
				message.style.color = 'green';
			}
    			message.className='unhidden';
			message.innerHTML = data;
			message.style.fontWeight="bold";
		      } 
		  }
    });
}
function update_client()
{
	var client_id = document.getElementById('customer_id').value;
	var name = document.getElementById('client_name').value;
	var tech_contact = document.getElementById('client_customer_tech_contact').value;
	var pm = document.getElementById('client_pm').value;
	var am = document.getElementById('client_am').value;
	var engineer = document.getElementById('client_ps_tech_contact').value;
	var version = document.getElementById('client_on_prem_version').value;
	var sharepoint = document.getElementById('client_sharepoint').value;
	var notes = document.getElementById('client_notes').value;
	var cust_status = document.getElementById('client_status').value;
	$.ajax({
			type: 'POST',
			url: 'update_client.php',
			data: {'client_id':client_id, 'name':name,'tech_contact':tech_contact,'client_pm':pm,'client_am':am,'engineer':engineer,'version':version,'sharepoint':sharepoint,'notes':notes,'status':cust_status},
	success:function(data){
		if (data!==null){
			message=document.getElementById("client_message");
			if (data.indexOf("ERR") !==-1) {
				message.style.color = 'red';
			}else{
				message.style.color = 'green';
			}
    			message.className='unhidden';
			message.innerHTML = data;
			message.style.fontWeight="bold";
		}
	}
		
	
	});
}
function export_csv()
{
	var customer_id = document.getElementById('customer_id').value;
	var customer_name = document.getElementById('customer_name').value;

	$.ajax({
		type: 'POST',
		url: 'export_csv.php',
		data: {'customer_id':customer_id,'customer_name': customer_name},
		success:function(data){
		if (data!==null){
			alert(data);
		}
	}
		
	
	});
}
	
</script>
<?php
$script_name=basename(__FILE__);
require_once(dirname($script_name).DIRECTORY_SEPARATOR.'conn.inc');
require_once(dirname($script_name).DIRECTORY_SEPARATOR.'locale.inc');
if (!isset($_SESSION['asper_user']) || !$_SESSION['asper_user']){
    require_once(dirname($script_name).DIRECTORY_SEPARATOR.'validate_session.inc');
}
$db=new SQLite3($dbfile,SQLITE3_OPEN_READWRITE) or die("Unable to connect to database $dbfile");
if (isset($_GET["id"])&& is_numeric ($_GET['id'])){
    $id = $_GET["id"];
    $name = $_GET["name"];
    $result=$db->query('select * from customers where id='.$id);
    $header=$name . ' - Customer details';
}elseif(!isset($_GET["edit"])){
    die('You need to pass a customer ID from customers.id.');
}

echo '
    <title>'.$header.'</title>
<body class=onprem>
Logged in as '.$_SESSION['asper_user'].'<br><a href=logout.php>Logout</a>
<br><br>
<input type="hidden" id="customer_id" name="customer_id" value="'.$id.'" />
<input type="hidden" id="customer_name" name="customer_name" value="'.$name.'" />
<h3><a href=#customer>Customer info:</a></h3>
<table id="customers" class=onprem>';
$index=0;
while($customers = $result->fetchArray(SQLITE3_ASSOC)){
    foreach($customers as $key => $val){
	if ($index%2){
	    $color='green';
	}else{
	    $color='yellow';
	}
	// no point in displaying customer ID.
	if ($key !== 'id'){
		echo "<div id=alt_caption alt='$val'><tr class=$color><td>$key</td><td><input type=text id='client_$key' class=k-textbox title='$val' value='$val'></td></tr></div>";
	}
	$index++;
    }
}
echo '<tr><td><input type=button id="updateclient" value="Update" onclick="javascript:update_client()"></td></tr>
<tr><td><div class=.k-slider id="client_message" class=hidden></div></td></tr>
    </table>
<br><a href=changelog.php?id='.$id.'>View changelog</a>
<br><input type=button id="exportcsv" value="Export to CSV" onclick="javascript:export_csv()">
    <table id="hosts">';
$result=$db->query('select hostname from hosts where customer_id='.$id);
echo '<h3><a href=#hosts>Hosts:</a></h3>';
while($hosts = $result->fetchArray(SQLITE3_ASSOC)){
	$index++;
    foreach($hosts as $key => $val){
	$result1=$db->query('select hostname, host_description, distro_version_arch, ssh_user, ssh_passwd, notes from hosts where hostname="'.$val.'"');
	while($host = $result1->fetchArray(SQLITE3_ASSOC)){
	    $id1=str_replace('.','',$val);
	    $id1=str_replace(' ','_',$val);
	    $orig_host=$val;
	    echo '<div class=.k-slider id=hide_show_div><input type=button id=hide_show value="'.$val.'" onclick="javascript:unhide(\''.$id1.'\')">'. '  |  ' .  $host['host_description'].'</div>
		<div id='.$id1.' class=hidden><ul id="navlist">';

	    echo '<li>Hostname: <input type=text class=k-textbox id="'.$id1.'_hostname" value="'.$host['hostname'].'"></il><br>';
	    echo '<li>Description: <input type=text class=k-textbox id="'.$id1.'_host_description" value="'.$host['host_description'].'"></il><br>';
	    echo '<li>Distro && arch: <input type=text class=k-textbox id="'.$id1.'_distro_version_arch" value="'.$host['distro_version_arch'].'"></il><br>';
	    echo '<li>User: <input type=text class=k-textbox id="'.$id1.'_ssh_user" value="'.$host['ssh_user'].'"></il><br>';
	    echo '<li>Password: <input type=password class=k-textbox id="'.$id1.'_ssh_passwd" value="'.$host['ssh_passwd'].'" onfocus="javascript:show_passwd(this)";></il><br>';
	    echo '<li>Notes: <textarea class=k-textbox id="'.$id1.'_notes" rows=3>'.$host['notes'].'</textarea><br>
	    <input type=button id="'.$id1.'_update_host" value="Update" onclick="javascript:update_host(\''.$orig_host.'\',\''.$id1.'\')"><br>
	    </div>
<div class=.k-slider id="host_message_'.$id1.'" class=hidden></div><br>';
	}
    }
	
}
echo '<tr></table><div class=.k-slider ><input type=button class=.k-button id=hide_show value="Add new host" onclick="javascript:unhide(\'add_form\')"></div>
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
		<input type="text" id="new_ssh_passwd" name="new_ssh_passwd" tabindex="50" autocomplete="on">
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
<div class=.k-slider id="new_host_message" class=hidden></div><br>
<table id="vpn">


<h3 class="onprem"><tr>';
$result=$db->query('select gateway from vpn where customer_id='.$id);
echo '<h3><a href="#vpn">VPN:</a></h3>';
while($vpns = $result->fetchArray(SQLITE3_ASSOC)){
	$index++;
    foreach($vpns as $key => $val){
	$result1=$db->query('select id,username,passwd,display_name,gateway,vpn_type,notes from vpn where customer_id=\''.$id.'\' and gateway=\''.$val.'\'');
	while($vpn = $result1->fetchArray(SQLITE3_ASSOC)){
	    $id1=str_replace('.','',$val);
	    $id1=str_replace(' ','',$val);
	    $orig_vpn=$val;
	    echo '<div class=.k-slider id=hide_show_div><input type=button id=hide_show_vpn value="'.$val.'" onclick="javascript:unhide(\''.$id1.'\')"></div>
		<div id='.$id1.' class=hidden><ul id="navlist">';

	    echo '<li>Description: <input type=text class=k-textbox id="'.$vpn['id'].'_display_name" value="'.$vpn['display_name'].'"></il><br>';
	    echo '<li>Type: <input type=text class=k-textbox id="'.$vpn['id'].'_type" value="'.$vpn['vpn_type'].'"></il><br>';
	    echo '<li>Gateway: <input type=text class=k-textbox id="'.$vpn['id'].'_gateway" value="'.$vpn['gateway'].'"></il><br>';
	    echo '<li>User: <input type=text class=k-textbox id="'.$vpn['id'].'_username" value="'.$vpn['username'].'"></il><br>';
	    echo '<li>Passwd: <input type=password class=k-textbox id="'.$vpn['id'].'_passwd" value="'.$vpn['passwd'].'"  onfocus="javascript:show_passwd(this)" ></il><br>
	   <div id="alt" alt="'.$vpn['notes'].'"><li>Notes: <textarea class=k-textbox id="'.$vpn['id'].'_notes" rows=3 alt="'.$vpn['notes'].'">'.$vpn['notes'].'</textarea><br>
	<input type=button id="'.$vpn['id'].'_update_vpn" value="Update" onclick="javascript:update_vpn(\''.$vpn['id'].'\')"><br>
	    </div><br>
	<div id="vpn_message_'.$vpn['id'].'" class=hidden></div><br>';
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
	<div class=.k-slider id="new_vpn_message" class=hidden></div><br>
<h3 class="onprem"><tr>
	<h3><a href="#ui">UI:</a></h3>';
$result=$db->query('select id from ui where customer_id='.$id);
	while($ui_ifs = $result->fetchArray(SQLITE3_ASSOC)){
		$index++;
	    foreach($ui_ifs as $key => $val){
	error_log("'select id, admin_console_url,admin_console_user,admin_console_passwd,kmc_url,kmc_user,kmc_passwd,kms_admin_url,kms_admin_user,kms_admin_passwd,notes from ui where id=$val\n",3,'/tmp/tmp');
		$result1=$db->query('select id, admin_console_url,admin_console_user,admin_console_passwd,kmc_url,kmc_user,kmc_passwd,kms_admin_url,kms_admin_user,kms_admin_passwd,notes,env from ui where id='.$val);
		while($ui_ifs = $result1->fetchArray(SQLITE3_ASSOC)){
		error_log(print_r($ui_ifs,true),3,'/tmp/dani');
		    echo '<div class=.k-slider id=hide_show_div><input type=button id=hide_show_ui_if value="'.$ui_ifs['env'].'" onclick="javascript:unhide(\''.$ui_ifs['env'].'\')"></div>
			<div id='.$ui_ifs['env'].' class=hidden><ul id="navlist">';

		    echo '<li>'.$app0.' URL: <input type=text class=k-textbox id="'.$ui_ifs['id'].'_admin_console_url" value="'.$ui_ifs['admin_console_url'].'"></il><br>';
		    echo '<li>'.$app0.' user: <input type=text class=k-textbox id="'.$ui_ifs['id'].'_admin_console_user" value="'.$ui_ifs['admin_console_user'].'"></il><br>';
		    echo '<li>'.$app0.' passwd: <input type=password class=k-textbox id="'.$ui_ifs['id'].'_admin_console_passwd" value="'.$ui_ifs['admin_console_passwd'].'"  onfocus="javascript:show_passwd(this)"></il><br>';
		    echo '<li>'.$app1.' URL: <input type=text class=k-textbox id="'.$ui_ifs['id'].'_kmc_url" value="'.$ui_ifs['kmc_url'].'"></il><br>';
		    echo '<li>'.$app1.' user: <input type=text class=k-textbox id="'.$ui_ifs['id'].'_kmc_user" value="'.$ui_ifs['kmc_user'].'"></il><br>';
		    echo '<li>'.$app1.' passwd: <input type=password class=k-textbox id="'.$ui_ifs['id'].'_kmc_passwd" value="'.$ui_ifs['kmc_passwd'].'" onfocus="javascript:show_passwd(this)"></il><br>';
		    echo '<li>'.$app2.' URL: <input type=text class=k-textbox id="'.$ui_ifs['id'].'_kms_admin_url" value="'.$ui_ifs['kms_admin_url'].'"></il><br>';
		    echo '<li>'.$app2.' user: <input type=text class=k-textbox id="'.$ui_ifs['id'].'_kms_admin_user" value="'.$ui_ifs['kms_admin_user'].'"></il><br>';
		    echo '<li>'.$app2.' passwd: <input type=password class=k-textbox id="'.$ui_ifs['id'].'_kms_admin_passwd" value="'.$ui_ifs['kms_admin_passwd'].'"  onfocus="javascript:show_passwd(this)"></il><br>';
		    echo '<li>Notes: <textarea class=k-textbox id="'.$ui_ifs['id'].'_notes" rows=3>'.$ui_ifs['notes'].'</textarea></il><br>
	<input type="hidden" id="env_'.$ui_ifs['id'].'" name="env_"'.$ui_ifs['id'].' value="'.$ui_ifs['env'].'" />
	<input type=button id="'.$ui_ifs['id'].'_update_ui_ifs" value="Update '.$ui_ifs['env'].'" onclick="javascript:update_ui_ifs(\''.$ui_ifs['id'].'\')">
	    <br></div>
	<div id="ui_message_'.$ui_ifs['id'].'" class=hidden></div><br>';
		    echo '</div><div class=.k-slider id="ui_message_'.$ui_ifs['id'].'" class=hidden></div>
			</form>';
		}
	    }
		
	}
	    echo'<form method="POST">
	    <div class=.k-slider ><input type=button class=.k-button id=hide_show_ui_if value="Add UI I/F" onclick="javascript:unhide(\'add_ui_ifs\')"></div>
	<div id=\'add_ui_ifs\' class=hidden>
	    <fieldset class=ui_ifs>
		<legend>UI</legend>
		<ul>
		    <li class="fl">
		    <label for="env">env:</label>
			<input type="text" id="env" name="env" tabindex="20" autocomplete="on">
		    </li>
		    <li class="fl">
		    <label for="admin_console_url">Admin console URL:</label>
			<input type="text" id="admin_console_url" name="admin_console_url" tabindex="25" autocomplete="on">
		    </li>

		    <li class="fl">
			<label for="admin_console_user">Admin console user:</label>
			<input type="text" id="admin_console_user" name="admin_console_user" tabindex="30" autocomplete="on">
		    </li>

		    <li class="fl">
			<label for="admin_console_passwd">Admin console passwd:</label>
			<input type="text" id="admin_console_passwd" name="admin_console_passwd" tabindex="35" autocomplete="on">
		    </li>

		    <li class="fl">
		    <label for="kmc_url">KMC URL:</label>
			<input type="text" id="kmc_url" name="kmc_url" tabindex="45" autocomplete="on">
		    </li>

		    <li class="fl">
			<label for="kmc_user">KMC user:</label>
			<input type="text" id="kmc_user" name="kmc_user" tabindex="50" autocomplete="on">
		    </li>

		    <li class="fl">
			<label for="kmc_passwd">KMC passwd:</label>
			<input type="text" id="kmc_passwd" name="kmc_passwd" tabindex="55" autocomplete="on">
		    </li>
		    <li class="fl">
		    <label for="kms_url">KMS URL:</label>
			<input type="text" id="kms_url" name="kms_url" tabindex="60" autocomplete="on">
		    </li>

		    <li class="fl">
			<label for="kms_user">KMS user:</label>
			<input type="text" id="kms_user" name="kms_user" tabindex="65" autocomplete="on">
		    </li>

		    <li class="fl">
			<label for="kms_passwd">KMS passwd:</label>
			<input type="text" id="kms_passwd" name="kms_passwd" tabindex="70" autocomplete="on">
		    </li>
		    <li class="fl">
		    <label for="ui_if_notes">Notes:</label>
			<input type="text" id="ui_ifs_notes" name="ui_notes" tabindex="75" autocomplete="on">
		    </li>
		    <li class="fl">
			<label for="update"></label>
			<input type=button value="update" onclick="javascript:add_ui_ifs();">
		    </li>

		    </ul>
	    </fieldset>
	</div><br>
	</form>
	<div class=.k-slider id="new_ui_message" class=hidden></div>
    </body>
    </html>';
?>
