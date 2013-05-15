#!/bin/bash
#
# Gemini auto installer
#
# The archive file provided in the command line is the kaltura package
# that is obtained from the svn, stripped of all svn meta data, and is in
# .tar.bz2
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
printf "Gemini auto installer version %s\n" "$version" | tee -a $logfile
printf "Kaltura install version %s\n" "$(grep -o '[0-9].*' installer/version.ini)" | tee -a $logfile
printf "Execution Time: %s\n" "$(date)"


usage () {
	printf "Usage: %s --archive <kaltura_archive_name>\n" "$0"
}

while :
do
    case $1 in
        -h | --help | -\?)
        	usage
		exit 0
		;;
	-a | --archive)
		archive_file=$2
		shift 2
		;;
        *)  
        	break
        	;;
    esac
done

# Verify configuration file
for var in log_file base_dir ntp_server mysql_host mysql_port mysql_user mysql_password  hostname kuser kgroup admin_user admin_pass kenvironment time_zone;do
	if [[ -z $var ]];then
		printf "The setting %s is missing a value in config.ini\n" "$var" | tee -a $logfile
		exit 1
	fi
done

# Packages required for the installer to work
if ! yum -y install wget ed &>> $logfile | tee -a $logfile;then
    printf "Error: unable to install base software which is required by the auto installer\n" | tee -a $logfile
	exit 1
fi

cat << EOL

The following components will be installed
	
	Prerequisites: $prereq
	MySQL: $mysql
	NTP: $ntp
	Pentaho: $pentaho
	Kaltura: $kaltura
	Patches: $patches
	
Proceed(y/n)?
EOL
read answer
if [[ $answer != 'y' ]];then
	printf "Quitting\n" | tee -a $logfile
	exit 0
fi

#Install each component
# Pre-requisites
if [[ $prereq == 'yes' ]];then
	printf "Installing pre-requesisites\n" | tee -a $logfile
	if ! install_prereq; then
		exit 1
	fi
fi

# NTP server
if [[ $ntp ==  'yes' ]];then
	printf "Installing and configuring NTP server\n" | tee -a $logfile
	install_ntp
fi

# MySQL Server
if [[ $mysql == 'yes' && $create_new_db == 'y' ]];then
	printf "Installing and configuring MySQL\n" | tee -a $logfile
	if ! install_mysql;then
		exit 1
	fi
elif [[ $mysql == 'no' && $create_new_db == 'y' ]];then
	printf "You specified an existing mysql server that doesn't contain a Kaltura database, checking connectivity\n" | tee -a $logfile
	if ! do_query "quit";then
		echo -e  "\e[00;31mError: unable to connect to the database server $mysql_host \e[00m" | tee -a $logfile
		exit 1
	else echo -e "\e[00;32mSuccess!\e[00m"
	fi
elif [[ $mysql == 'no' && $create_new_db != 'y' ]];then
	printf "Checking to see if the kaltura database exists\n" | tee -a $logfile
	if ! do_query "use kaltura";then
		printf "Warning: the kaltura database does not exist\n" | tee -a $logfile
	fi	
else
	printf "Error: you can not choose to install a new mysql server but also specifiy not to create a new database\n" | tee -a $logfile
	printf "Configuration settings as follows - mysql:%s create_new_db:%s\n" "$mysql" "$create_new_db"
	exit 1
fi

# Pentaho
if [[ $pentaho == 'yes' ]];then
    printf "Installing and configuring Pentaho\n" | tee -a $logfile
    if ! install_pentaho;then
        exit 1
    fi
fi

# Kaltura
if [[ $kaltura == 'yes' ]];then
	printf  "Installing and configuring Kaltura\n" | tee -a $logfile
	if ! install_kaltura;then
		exit 1
	fi
fi

# Patches
if [[ $patches == 'yes' ]];then
	printf "Applying Patches\n" | tee -a $logfile
	if ! install_patches;then
		printf "Warning: unable to apply some or all patches\n" | tee -a $logfile
	fi
fi

printf "Installation complete\n" | tee -a $logfile
exit 0
