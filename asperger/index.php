<?php session_start();
?>
<link type="text/css" href="css/onprem.css" rel="Stylesheet" />
<script type="text/javascript" src="js/jquery.min.js"></script>
<script type="text/javascript" src="js/jquery.js"></script>
<script type="text/javascript" src="js/axuploader.js"></script>
<html>
<head>
</head>
<script type="text/javascript">
	$(document).ready(function(){
		$('.prova').axuploader({
			url:'upload.php',
			finish:function(x,files){  },
			enable:true,
			remotePath:function(){
				return '/tmp/up_files/';
			}
		});
	});
	function axuploader()
	{
		$.ajax({
			url:'axuploader/upload.php',
			finish:function(x,files){  },
			enable:true,
			remotePath:function(){
				return '/tmp/up_files/';
			}
		});
	}
    function unhide_add(divID) 
    {
	var item = document.getElementById(divID);
	item.className='unhidden';
	var name=document.getElementById('name');
	name.focus();
    }

    function add_customer()
    {
	var name = document.getElementById('name').value;
	var customer_tech_contact = document.getElementById('customer_tech_contact').value;
	var pm = document.getElementById('pm').value;
	var am = document.getElementById('am').value;
	var ps_tech_contact = document.getElementById('ps_tech_contact').value;
	var on_prem_version = document.getElementById('on_prem_version').value;
	var notes = document.getElementById('notes').value;
	var cust_status = document.getElementById('status').value;
	$.ajax({
		  type: 'POST',
		  url: 'add_customer.php',
		  data: {'name': name,'customer_tech_contact': customer_tech_contact,'pm': pm, 'am': am, 'ps_tech_contact': ps_tech_contact, 'on_prem_version': on_prem_version, 'notes': notes,'status':cust_status},
		  success: function(data){
		      if (data!==null){
			  alert(data);
		      } 
		  }
	});
    	//document.location.reload();
    }
</script>
<body class="onprem">
<?php
$script_name=basename(__FILE__);
require_once(dirname($script_name).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_user']) || !$_SESSION['asper_user']){
    require_once(dirname($script_name).DIRECTORY_SEPARATOR.'validate_session.inc');
}
if (isset($_GET["orderby"])){
    $order_by = $_GET["orderby"];
}else{
    $order_by = 'name';
}
echo '<title>OnPrem Clients ordered by '.$order_by.'</title>
Logged in as '.$_SESSION['asper_user'].'<br><a href=logout.php>Logout</a>
<br><br>
<div class=.k-slider ><input type=button class=.k-button id=hide_show value="Add new" onclick="javascript:unhide_add(\'add_form\')"></div>';
$db=new SQLite3($dbfile,SQLITE3_OPEN_READONLY) or die("Unable to connect to database $dbfile");
$result=$db->query('select * from customers order by '.$order_by);
$index=0;
while($res = $result->fetchArray(SQLITE3_ASSOC)){
    if ($index===0){
	echo '<table>
	<h3 class="onprem">OnPrem Clients (by '.$order_by.')<h3>
	<tr>
	<th><a href='.$script_name.'?orderby=id>ID</a></th>
	<th><a href='.$script_name.'?orderby=name>Client name</a></th>
	<th><a href='.$script_name.'?orderby=customer_tech_contact>Technical contact</a></th>
	<th><a href='.$script_name.'?orderby=pm>PM</a></th>
	<th><a href='.$script_name.'?orderby=am>AM</a></th>
	<th><a href='.$script_name.'?orderby=ps_tech_contact>PS Engineer</a></th>
	<th><a href='.$script_name.'?orderby=on_prem_version>Version</a></th>
	<th><a href='.$script_name.'>Changelog</th>
	<th><a href='.$script_name.'?orderby=status>Status</th>
	<th><a href='.$script_name.'>Notes</th>
	<th><a href='.$script_name.'>SharePoint</th>
	</tr>';
    }
    if ($index%2){
	$color='green';
    }else{
	$color='yellow';
    }
    echo '<tr class="'.$color.'">
    <td> <a href=customer.php?id='.$res['id'].'&name='.$res['name'].'>'. $res['id'].'</a></td>
    <td><a href=customer.php?id='.$res['id'].'&name='.$res['name'].'>' . $res['name'].'</a></td>
    <td>' . $res['customer_tech_contact'].'</td>
    <td>' . $res['pm'].'</td>'. '</td>
    <td>' . $res['am'].'</td>
    <td>' . $res['ps_tech_contact'].'</td>
    <td>' . $res['on_prem_version'].'</td>
    <td><a href="changelog.php?id='.$res['id'].'">Changelog</a></td>
    <td>' . $res['status'].'</td>
    <td>' . $res['notes'].'</td>
    <td align="center"><a href="' . $res['sharepoint']. '"><img src="images/sharepoint.png" /></a></td>
    </tr>';
    $index++;
}
echo '</table><br>
		
		
<form method="GET" action="javascript:add_customer();">
<div class=.k-slider ><input type=button class=.k-button id=hide_show value="Add new" onclick="javascript:unhide_add(\'add_form\')"></div>
<div id=\'add_form\' class=hidden>
    <fieldset>
	<legend>Add customer</legend>
	<ul>
	    <li class="fl">
		<label for="name">Name:</label>
		<input type="text" id="name" name="name" tabindex="10" autocomplete="on">
	    </li>

	    <li class="fl">
		<label for="customer_tech_contact">Customer tech contact:</label>
		<input type="text" id="customer_tech_contact" name="customer_tech_contact" tabindex="20" autocomplete="on">
	    </li>

	    <li class="fl">
		<label for="pm">PM:</label>
		<input type="text" id="pm" name="pm" tabindex="30" autocomplete="on">
	    </li>

	    <li class="fl">
		<label for="am">AM:</label>
		<input type="text" id="am" name="am" tabindex="30" autocomplete="on">
	    </li>
	    <li class="fl">
		<label for="ps_tech_contact">PS tech guy:</label>
		<input type="text" id="ps_tech_contact" name="ps_tech_contact" tabindex="40" autocomplete="on">
	    </li>
	    <li class="fl">
		<label for="on_prem_version">OnPrem version:</label>
		<input type="text" id="on_prem_version" name="on_prem_version" tabindex="40" autocomplete="on" value="Falcon2">
	    </li>
	    <li class="fl">
		<label for="notes">Notes:</label>
		<input type="text" id="notes" name="notes" tabindex="40" autocomplete="on">
	    </li>
	    <li class="fl">
		<label for="notes">Status:</label>
		<input type="text" id="status" name="status" tabindex="40" autocomplete="on" value="ACTIVE">
	    </li>
	    <li class="fl">
		<label for="update"></label>
		<input type=submit value="update">
	    </li>

	    </ul></div>
    </fieldset>

</form>
</body>
		
		
		</html>';
?>
