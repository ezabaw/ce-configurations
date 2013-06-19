# #!/bin/bash
#
# Gemini uninstaller
#
version="0.2"
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
while true; do
	cat << EOL
	
(1) Uninstall all kaltura components
	- Remove all kaltura components
(2) Wipe Kaltura database
	- Drop all kaltura databse
(q) Quit
EOL

	read answer
	# Remove Kaltura
	if [ $answer -eq 1 ];then
		printf "Removing Kaltura\n"
		if uninstall_kaltura;then
			printf "Kaltura successfully removed\n"
		else
			printf "Warning: unable to remove Kaltura\n"
		fi
	# Remove the kaltura database
	elif [ $answer -eq 2 ];then
		printf "Dropping kaltura MySQL databases\n\n"
		# Remove all the databases
		for v in kaltura kaltura_sphinx_log kalturadw kalturadw_bisources kalturadw_ds kalturalog;do
			if ! do_query "use $v";then
				printf "$v does not exist\n" "$v"
			elif ! do_query "drop database $v";then
				printf "Unable to drop $v\n" "$v"
			else	
				printf "$v dropped\n" "$s"
			fi
		done
		# Remove the kaltura users, since there is no wildcard support this assumes the
		# installer always creates the same two users
		for v in $mysql_kaltura_user $mysql_etl_user;do
			if ! do_query "drop user '$v'@'%'";then
				printf "Unable to drop user $v\n" "$v"
			fi
		done
	elif [ $answer -eq 3 ];then
		printf "Not done yet\n"
	elif [ $answer == 'q' ];then
		exit 0
	else
		printf "Invalid selection\n\n"
	fi
done
