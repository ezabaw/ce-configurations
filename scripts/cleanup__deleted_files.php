<?php
// Deletes all files for assets that are marked as deleted interactively
// this script only applies to local files
// Usage delete_entry.php  <dbhost> <dbuser> <dbpass>

if (count($argv) < 4){
	echo "Invalid number of arguments\n";
	exit();
}

$dbhost = $argv[1];
$dbuser	= $argv[2];
$dbpass = $argv[3];

// Connect to MySQL database
$mysql = mysql_connect($dbhost,$dbuser,$dbpass);
if (!$mysql){
	die('Could not connect to database server' . mysql_error(). "\n");
}
// Find all assets that are marked as deleted and local
$query = sprintf("SELECT id,file_root,file_path FROM kaltura.file_sync WHERE status=3 AND file_type=1");
$result = mysql_query($query);
if (!$result) { 
	die("Query failed:" . mysql_error() . "\n");
}

// Process each file
$totalSize = 0;
$files = array();
while ($row = mysql_fetch_assoc($result)){
	$file = $row['file_root'] . $row['file_path'];
	// Check if the file still exists locally
	if ( !file_exists($file)){
		echo "File:$file does not exist, skipping\n";
		continue;
	}
	// Filesize is obtained through a system command due to php
	// using a 32-bit signed int
	$fileSize = exec("stat -c %s $file",$output,$returnval);
	if ($returnval != 0){
		echo "error obtaining file size for $file through OS command, skipping";
		echo print_r($output);
		continue;
	}
	$files[$row['id']] = $file;
	$totalSize =  $fileSize + $totalSize;
	echo "File:" . $file . " Size:$fileSize\n";
}
// Check if there is a point to continuing
if ($totalSize == 0){
	echo "Nothing to delete\n";
	exit();
}
// This is a confirmation on the total size, hopefully if the size seems suspciously large
// users will abort
echo "\nPlease confirm you are want to delete " .  round((($totalSize / 1024) / 1024),2) . " Megabytes (YES)?\n";
$handle = fopen("php://stdin","r");
$line = fgets($handle);
if (trim($line) != 'YES'){
	echo "Exiting\n";
	exit;
}
// Delete each file from the file system and set the status to purged
foreach ($files as $i => $file){
	if (unlink($file)){
		echo "File:$file deleted sucessfully ";
		$query = sprintf("update kaltura.file_sync set status=4 WHERE id=$i");
		$result = mysql_query($query);
		// If for some reason we can't set the file status, it means a mysql error
		// this would be unusal if we were able to execute the earlier mysql query
		if (!$result) { 
			echo "Unable to set file status\n" . mysql_error() . "\n";
			exit();
		}	
		echo "Asset status set as purged\n";
		
	}	
	// Error attempting to delete the file, probably permissions
	else{
		echo "Unable to delete $file check permissions\n";
	}
}
?>
