<?php
session_start();
require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'conn.inc');
if (!isset($_SESSION['asper_user']) || !$_SESSION['asper_user']){
    require_once(dirname($script_name).DIRECTORY_SEPARATOR.'validate_session.inc');
}

function mail_it($to, $files, $sendermail,$subject)
{
    // email fields: to, from, subject, and so on
    $from = "Asperger gnome <".$sendermail.">";
    //$subject = date("d.M H:i")." F=".count($files);
    //$message = date("Y.m.d H:i:s")."\n".count($files)." attachments";
    $message='Hello '.$_SESSION['asper_user'].",\n\nAttached are the CSVs you requested.\n\nMay the source be with you,\nThe Asperger gnome";
    $headers = "From: $from";
 
    // boundary
    $semi_rand = md5(time());
    $mime_boundary = "==Multipart_Boundary_x{$semi_rand}x";
 
    // headers for attachment
    $headers .= "\nMIME-Version: 1.0\n" . "Content-Type: multipart/mixed;\n" . " boundary=\"{$mime_boundary}\"";
 
    // multipart boundary
    $message = "--{$mime_boundary}\n" . "Content-Type: text/plain; charset=\"iso-8859-1\"\n" .
    "Content-Transfer-Encoding: 7bit\n\n" . $message . "\n\n";
 
    // preparing attachments
    for($i=0;$i<count($files);$i++){
        if(is_file($files[$i])){
            $message .= "--{$mime_boundary}\n";
            $fp =    @fopen($files[$i],"rb");
        $data =    @fread($fp,filesize($files[$i]));
                    @fclose($fp);
            $data = chunk_split(base64_encode($data));
            $message .= "Content-Type: application/octet-stream; name=\"".basename($files[$i])."\"\n" .
            "Content-Description: ".basename($files[$i])."\n" .
            "Content-Disposition: attachment;\n" . " filename=\"".basename($files[$i])."\"; size=".filesize($files[$i]).";\n" .
            "Content-Transfer-Encoding: base64\n\n" . $data . "\n\n";
            }
        }
	$message .= "--{$mime_boundary}--";
	$returnpath = "-f" . $sendermail;
	$ok = mail($to, $subject, $message, $headers, $returnpath);
	if($ok){ 
		return true; 
	} else { 
		return false; 
	}
}
$id=$_POST['customer_id'];
$name=$_POST['customer_name'];
exec("sqlite3 -csv $dbfile 'select * from hosts where customer_id=$id' >/tmp/$name".'_hosts.csv',$out,$ret);
if ($ret!==0){
	$msg="Failed to export hosts for $name\n";
}
exec("sqlite3 -csv $dbfile 'select * from vpn where customer_id=$id' >/tmp/$name".'_vpns.csv',$out,$ret);
if ($ret!==0){
	$msg.="Failed to export vpns for $name\n";
}
exec("sqlite3 -csv $dbfile 'select * from ui where customer_id=$id' >/tmp/$name".'_ui.csv',$out,$ret);
if ($ret!==0){
	$msg.="Failed to export ui for $name\n";
}
if (!isset($msg)){
	$files=array('/tmp/'.$name.'_hosts.csv','/tmp/'.$name.'_vpns.csv','/tmp/'.$name.'_ui.csv');
	$msg="Export done successfully. Mail will be sent to ".$_SESSION['asper_user']."@$domain\n";
	$returnc=mail_it($_SESSION['asper_user'].'@'.$domain, $files, 'asperger@'.$domain,'Customer info for '.$name);
}
foreach ($files as $file){
	unlink($file);
}
echo $msg;
?>
