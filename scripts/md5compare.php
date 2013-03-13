<?php

// This program takes md5 digest files as produced by "md5sum" and does a compare between them
// As a utility program this does not check for bad files or improper user input, call correctly

$base_digest = fopen($argv[1], "r");
$generated_digest = fopen($argv[2], "r");

$base_array = array();
$generated_array = array();

# Load both files into arrays for a comparison
if ($base_digest){
        while (($line = fgets($base_digest,4096)) != false){
                $arr = explode(" " , rtrim($line));
                $base_array["$arr[1]"] = "$arr[0]";


        }
}

if ($generated_digest){
        while (($line = fgets($generated_digest,4096)) != false){
                $arr = explode(" ", rtrim($line));
                $generated_array["$arr[1]"] = "$arr[0]";

        }
}
$missing = fopen("/tmp/md5missing","w+");
$additional = fopen("/tmp/md5added","w+");
$changed = fopen("/tmp/md5changed","w+");

# Check to see if the file (key in the array) is present in the source
# array, if so then check if the md5 matches. If the file is not present then it is
# an additional file, if the md5 doesn't match, it's changed.
foreach ($generated_array as $file => $md5){

        #echo "Processing File: $file\n";
        #echo "Which has MD5: $md5\n";
        if(array_key_exists($file,$base_array )){
                if ( $base_array[$file] != $md5){
                        fwrite($changed,$file);
                }
        }
        else {
                fwrite($additional,$file);
        }
}

# Check to see if any files present in the source digest are not present in the
# generated disgest.
foreach ($base_digest as $file => $md5){
        #echo "Processing File: $file\n";
        #echo "While has MD5: $md5\n";
        if ( isset($generated_array[$file]) ){
                fwrite($missing,$file);
        }
}
