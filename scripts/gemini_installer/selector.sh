#!/bin/bash
# Kaltura selector script
# This changes the configuration of the kaltura installation provided by the first parameter

source functions.rc
usage () {
        printf "Usage: %s --b <kaltura_base_directory>\n" "$0"
}

base_dir=/opt/kaltura
logfile=/var/log/installer.log

while :
do
    case $1 in
        -h | --help | -\?)
                usage
                exit 0
                ;;
        -b | --base)
                base_dir=$2
                shift 2
                ;;
        *)
        break
        ;;
    esac
done


# Checks to see if the Sphinx service is running
check_sphinx(){
if pgrep -f searchd > /dev/null;then
	sphinx_status=yes
else
	sphinx_status=no
fi
}

# Turn the sphinx service on or off
set_sphinx(){
	if [[ $sphinx_status == "yes" ]];then
		service kaltura_sphinx stop &>> $logfile
		chkconfig kaltura_sphinx off
	else 
		service kaltura_sphinx start &>> $logfile
		chkconfig kaltura_sphinx on
	fi
}

# Checks to see if the Batch service is running
check_batch(){
	# Obtain the batch ID
	read_param id $base_dir/app/configurations/batch/scheduler.conf
	batch_id=$returnval
	if pgrep -f KGenericBatchMgr > /dev/null;then
		batch_status=yes
	else
		batch_status=no
	fi
	
}


set_batch(){
	# Turn off all batch processing
	if [[ $batch_status == "yes" && $transcode_status == "no" ]];then
		service kaltura_batch stop &>> $logfile
		chkconfig kaltura_batch off
	# Turn back on the entire server
	else
		service kaltura_batch start &>> $logfile
		chkconfig kaltura_batch on
		# Change the batch ID
		printf "Enter a new batch ID ($batch_id)"
		read answer
		if [[ ! -z $answer ]];then	
			batch_id=$answer
		fi
		write_param id $batch_id $base_dir/app/configurations/batch/scheduler.conf
	fi
	
}

# Check to see if red5 is running
check_red5(){
	if pgrep -f red5 > /dev/null;then
		red5_status=yes
	else
		red5_status=no
	fi
}

# Change the red5 service
set_red5(){
	if [[ $red5_status == "yes" ]];then
		service red5 stop &>> $logfile
		chkconfig red5 off
	else
		service red5 start &>> $logfile
		chkconfig red5 on
	fi
}

check_httpd(){
	if pgrep -f httpd > /dev/null;then
		httpd_status=yes
	else
		httpd_status=no
	fi
}

set_httpd(){
	if [[ $httpd_status == "yes" ]];then
		service httpd stop &>> $logfile
		chkconfig httpd off
	else
		service httpd start &>> $logfile
		chkconfig httpd on
	fi
}

# Both files must be present or DWH is assumed to be off
check_dwh(){
	if [[ -f /etc/cron.d/dwh && -f /etc/cron.d/dwh_crontab ]];then
		dwh_status=yes
	else
		dwh_status=no
	fi
}

set_dwh(){
	if [[ $dwh_status == "yes" ]];then
		ln -s $base_dir/app/configurations/cron/dwh /etc/cron.d/dwh
		ln -s $base_dir/app/configurations/cron/dwh_crontab
	else 
		rm -r /etc/cron.d/dwh
		rm -r /etc/cron.d/dwh_crontab
	fi
}

while :
do
	# Check the status of each component
	for var in check_transcode check_batch check_sphinx check_red5 check_httpd check_dwh;do
		eval ${var}
	done
	#Display current status and options to modify the installation
	printf "\nKaltura Version: %s\n" "$(cat $base_dir/app/VERSION.txt)"
	cat << EOL
Select which mode you would like to switch
	
(1) Batch: $batch_status ID: $batch_id
(2) Sphinx: $sphinx_status
(3) Red5: $red5_status
(4) API (httpd): $httpd_status
(5) DWH: $dwh_status
(q) Quit\

EOL

# I don't like switch, that's why it's this way
	read answer
	if [[ $answer -eq 1 ]];then
		set_batch
	elif [[ $answer -eq 2 ]];then 
		set_sphinx
	elif [[ $answer -eq 3 ]];then
		set_red5
	elif [[ $answer -eq 4 ]];then
		set_httpd
	elif [[ $answer -eq 5 ]];then
		set_dwh
	elif [[ $answer == "q" ]];then
		exit 0
	else 
		printf "Invalid option\n"
	fi
done