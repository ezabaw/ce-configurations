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
                returnval=Yes
        else
                returnval=No
        fi
}

# Set the transcode process on or off
set_transcode(){
	if [[ $1 == "Yes" ]];then
		# Change the convert line in the batch.ini
		sed -i "s|KAsyncConvert[[:space:]]*=[[:space:]]*1|KAsyncConvert = 0|g" $base_dir/app/configurations/batch/batch.ini
	else
		sed -i "s|KAsyncConvert[[:space:]]*=[[:space:]]*0|KAsyncConvert = 1|g" $base_dir/app/configurations/batch/batch.ini
	fi
}


# Checks to see if the Sphinx service is running
check_sphinx(){
if pgrep -f searchd > /dev/null;then
	returnval=Yes
else
	returnval=No
fi
}

# Turn the sphinx service on or off
set_sphinx(){
	if [[ $1 == "Yes" ]];then
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
		returnval=Yes
	else
		returnval=No
	fi
}

# Turn the batch process on or off
set_batch(){
	if [[ $1 == "Yes" ]];then
		service kaltura_batch stop &>> $logfile
		chkconfig kaltura_batch off
	else
		service kaltura_batch start &>> $logfile
		chkconfig kaltura_batch on
	fi
}

while :
do
	#Display current status and options to modify the installation
	printf "Kaltura Version: %s\n" "$(cat $base_dir/app/VERSION.txt)"
	printf "Select which mode you would like to switch\n"
	check_transcode;transcode_status=$returnval
	printf "(1) Transcoder: %s\n" "$transcode_status"
	check_batch;batch_status=$returnval
	printf "(2) Batch: %s\n" "$batch_status"
	check_sphinx;sphinx_status=$returnval
	printf "(3) Sphinx: %s\n" "$sphinx_status"
	printf "\n(q) Quit\n"
	read answer
	if [[ $answer -eq 1 ]];then
		set_transcode $transcode_status
	elif [[ $answer -eq 2 ]];then
		set_batch $batch_status
	elif [[ $answer -eq 3 ]];then 
		set_sphinx $sphinx_status
	elif [[ $answer == "q" ]];then
		exit 0
	else 
		printf "Invalid option\n"
	fi
done
