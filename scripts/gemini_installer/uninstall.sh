# #!/bin/bash
#
# Gemini uninstaller
#
version="0.1"
source config.ini

for f in components/*.rc;do source $f;done


cat << EOL
  _  _     _    _   _____ _   _ ____      _    
 | |/ /   / \  | | |_   _| | | |  _ \    / \   
 | ' /   / _ \ | |   | | | | | | |_) |  / _ \  
 | . \  / ___ \| |___| | | |_| |  _ <  / ___ \ 
 |_|\_\/_/   \_\_____|_|  \___/|_| \_\/_/   \_\
                                               
											   
EOL
printf "Gemini uninstaller version %s\n" "$version" | tee -a $logfile
printf "Execution Time: %s\n" "$(date)"

usage () {
	printf "Usage: %s" "$0"
}

while :
do
    case $1 in
        -h | --help | -\?)
        	usage
		exit 0
		;;
        *)  
        break
        ;;
    esac
done

cat << EOL
(1) Uninstall all kaltura components
	- Remove all kaltura components
(2) Wipe Kaltura database
	- Drop all kaltura databse
(3) Return system to clean state
	- Removes packages, Kaltura, and drops the database if it's local
EOL

