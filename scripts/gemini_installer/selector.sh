#!/bin/bash
# Kaltura selector script
# This changes the configuration of the kaltura installation provided by the first parameter

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

# Check the transcode
check_transcode(){
        pval=$(grep -e "KAsyncConvert[[:space:]]*=[[:space:]]*" $base_dir/app/configurations/batch/batch.ini | awk '{print $3}')
        if [[ -z $pval ]];then
                printf "Error: unable to identify configuration variable $1\n"
                returnval=Error
        elif [[ $pval -eq 1 ]];then
                returnval=yes
        else
                returnval=no
        fi
}

# Set the transcode process on or off
set_transcode(){
	if [[ $1 == "yes" ]];then
		# Change the convert line in the batch.ini
		sed -i "s|KAsyncConvert[[:space:]]*=[[:space:]]*1|KAsyncConvert = 0|g" $base_dir/app/configurations/batch/batch.ini
	else
		sed -i "s|KAsyncConvert[[:space:]]*=[[:space:]]*0|KAsyncConvert = 1|g" $base_dir/app/configurations/batch/batch.ini
	fi
}


# Checks to see if the Sphinx service is running
check_sphinx(){
if pgrep -f searchd > /dev/null;then
	returnval=yes
else
	returnval=no
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
	if pgrep -f KGenericBatchMgr > /dev/null;then
		returnval=yes
	else
		returnval=no
	fi
}

# Turn the batch process on or off, we perform the operation to flip the current status
# that's why transcode has it's own function, the transcode status here only determines
# how to turn the batch off
set_batch(){
	# Turn off all batch processing
	if [[ $batch_status == "yes" && $transcode_status == "no" ]];then
		service kaltura_batch stop &>> $logfile
		chkconfig kaltura_batch off
	# Disable batch processing only but keep the transcoding
	elif [[ $1 == "yes" && $transcode_status == "yes" ]];then
	echo "temp"
	
	# Re-enable batch processing that was disabled
	elif [[ $1 == "no" && transcode_status == "yes" ]];then
	echo "temp"
	# Turn back on the entire server
	else
		service kaltura_batch start &>> $logfile
		chkconfig kaltura_batch on
	fi
}
# Check to see if red5 is running
check_red5(){
	if pgrep -f red5 > /dev/null;then
		returnval=yes
	else
		returnval=no
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
		returnval=yes
	else
		returnval=no
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
		returnval=yes
	else
		returnval=no
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
	#Display current status and options to modify the installation
	printf "\nKaltura Version: %s\n\n" "$(cat $base_dir/app/VERSION.txt)"
	printf "Select which mode you would like to switch\n\n"
	check_transcode;transcode_status=$returnval
	printf "(1) Transcoder: %s\n" "$transcode_status"
	check_batch;batch_status=$returnval
	printf "(2) Batch: %s\n" "$batch_status"
	check_sphinx;sphinx_status=$returnval
	printf "(3) Sphinx: %s\n" "$sphinx_status"
	check_red5;red5_status=$returnval
	printf "(4) Red5: %s\n" "$red5_status"
	check_httpd;httpd_status=$returnval
	printf "(5) API (httpd) %s\n" "$httpd_status"
	check_dwh;dwh_status=$returnval
	printf "(6) DWH %s\n" "$dwh_status"
	printf "\n(q) Quit\n"
	read answer
	if [[ $answer -eq 1 ]];then
		set_transcode
	elif [[ $answer -eq 2 ]];then
		set_batch
	elif [[ $answer -eq 3 ]];then 
		set_sphinx
	elif [[ $answer -eq 4 ]];then
		set_red5
	elif [[ $answer -eq 5 ]];then
		set_httpd
	elif [[ $answer -eq 6 ]];then
		set_dwh
	elif [[ $answer == "q" ]];then
		exit 0
	else 
		printf "Invalid option\n"
	fi
done
