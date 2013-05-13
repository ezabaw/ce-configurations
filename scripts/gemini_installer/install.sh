#!/bin/bash
#
# Gemini auto installer
#
# The archive file provided in the command line is the kaltura package
# that is obtained from the svn, stripped of all svn meta data, and is in
# .tar.bz2
#
version="0.1"
source config_file

for f in components/*.rc;do source $f;done


printf "\----------------------------------------------\n" | tee -a $logfile
printf "Gemini auto installer version %s\n" "$version" | tee -a $logfile
printf "Kaltura install version %s\n" "$(grep -o '[0-9].*' installer/version.ini)" | tee -a $logfile
printf "Execution Time: %s\n" "$(date)"
printf "\----------------------------------------------\n" | tee -a $logfile

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

if [[ -z $archive_file ]];then
	printf "Kaltura package file not found\n" | tee -a $logfile
else
	# Some details about the installation file
	printf "Installation file: %s Size:%s Date:%s\n" "${archive_file}" "$(du -bh $archive_file)" "$(stat ${archive_file} --printf %y |awk '{print $1}')"
fi

# Verify configuration file
for var in log_file base_dir ntp_server smtp_server mysql_server mysql_user mysql_password hostname mysql ntp red5 prereq pentaho kaltura patches smtp sphinx;do
	if [[ -z $var ]];then
		printf "The setting %s is missing a value in %s\n" "$var" "$config_file"
		exit 1
	fi
done

# Installer requirements
if ! yum -y install wget bzip2 &>> $logfile | tee -a $logfile;then
    printf "Error: unable to instal wget which is required by the installer\n" | tee -a $logfile
fi

#Install each component, the order matter ( mysql and pentaho before kaltura)
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
if [[ $mysql == 'yes' && $create_new_db != 'y' ]];then
	printf "Installing and configuring MySQL\n" | tee -a $logfile
	if ! install_mysql;then
		exit 1
	fi
elif [[ $mysql == 'no' && $create_new_db == 'y' ]];then
	printf "You specified an existing mysql server with no database, checking connectivity\n" | tee -a $logfile
	# check connectivity to database TODO
elif [[ $mysql == 'no' && $create_new_db != 'y' ]];then
	printf "You specified that an exsting kaltura database exists, checking connectivity and database\n" | tee -a $logfile
	# check connectivity and database existence TODO
	
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

# Red5
if [[ $red5 == 'yes' ]];then
	printf "Installing and configuring Red5\n" | tee -a $logfile
	if ! install_red5;then
		exit 1
	fi
fi

# Patches
if [[ $patches == 'yes' ]];then
	printf "Applying Patches\n" | tee -a $logfile
	if ! install_patches;then
		printf "Warning: unable to apply some/all patches\n" | tee -a $logfile
	fi
fi

printf "Installation complete\n" | tee -a $logfile
exit 0
