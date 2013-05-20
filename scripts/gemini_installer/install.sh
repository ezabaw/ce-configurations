#!/bin/bash
#
# Gemini auto installer
#
# The archive file provided in the command line is the kaltura package
# that is obtained from the svn, stripped of all svn meta data, and is in
# .tar.bz2
#

source config.ini
for f in components/*.rc;do source $f;done


cat << EOL
  _  _     _    _   _____ _   _ ____      _    
 | |/ /   / \  | | |_   _| | | |  _ \    / \   
 | ' /   / _ \ | |   | | | | | | |_) |  / _ \  
 | . \  / ___ \| |___| | | |_| |  _ <  / ___ \ 
 |_|\_\/_/   \_\_____|_|  \___/|_| \_\/_/   \_\
                                               
											   
EOL
printf "Gemini auto installer\n"
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
if ! yum -y install nc wget ed &>> $logfile | tee -a $logfile;then
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
# Option 1 install new MySQL server
if [[ $mysql -eq '1' ]];then
	printf "Installing and configuring MySQL\n" | tee -a $logfile
	if ! install_mysql;then
		exit 1
	fi
	create_new_db=y
# Option 2 using existing server but install a new database
elif [[ $mysql -eq '2' ]];then
	printf "You specified an existing mysql server that doesn't contain a Kaltura database, checking connectivity\n" | tee -a $logfile
	# Test connectivity to the server
	if ! do_query "quit" &> /dev/null;then
		echo -e  "\e[00;31mError: unable to connect to the database server $mysql_host \e[00m" | tee -a $logfile
		exit 1
	else 
		echo -e "\e[00;32mSuccess!\e[00m"
	fi
	# Check to make sure that a Kaltura database doesn't already exist
	if do_query "use kaltura" &> /dev/null;then
		echo -e "\e[00;31mError: a Kaltura database already exists on $mysql_host \e[00m" | tee -a $logfile
		exit 1
	fi
	# Sets the variable for the kaltura installation
	create_new_db=y
elif [[ $mysql -eq '3' ]];then
	printf "You specified an existing mysql server that contains a Kaltura database, checking connectivity\n" | tee -a $logfile
	# Test connectivity to the server
	if ! do_query "quit" &> /dev/null;then
		echo -e  "\e[00;31mWarning: unable to connect to the database server $mysql_host \e[00m" | tee -a $logfile
	else 
		echo -e "\e[00;32mSuccess!\e[00m"
	fi
	# Sets the variable for the kaltura installation
	create_new_db=n
else
	printf "Invalid option for MySQL settings in configuration, this variable is required\n" | tee -a $logfile
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

exit 0
