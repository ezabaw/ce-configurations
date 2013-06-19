#!/bin/bash
# Kaltura selector script
# This changes the configuration of the kaltura installation provided by the first parameter

source utils/functions.rc
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
	if [ $sphinx_status == "yes" ];then
		service kaltura_sphinx stop >> $logfile 2>&1
		service kaltura_populate stop >> $logfile 2>&1
		chkconfig kaltura_sphinx off
		chkconfig kaltura_populate off
		rm -f /etc/init.d/kaltura_sphinx
		rm -f /etc/init.d/kaltura_populate
	else 
		ln -s $base_dir/app/scripts/kaltura_sphinx.sh /etc/init.d/kaltura_sphinx
		ln -s $base_dir/app/scripts/kaltura_populate.sh /etc/init.d/kaltura_populate
		service kaltura_sphinx start >> $logfile 2>&1
		service kaltura_populate start >> $logfile 2>&1
		chkconfig kaltura_sphinx on
		chkconfig kaltura_populate on
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
	if [ $batch_status == "yes" ]; then
		service kaltura_batch stop >> $logfile 2>&1
		chkconfig kaltura_batch off
		rm -f /etc/init.d/kaltura_batch
	# Turn back on the entire server
	else
		ln -s $base_dir/app/scripts/kaltura_batch.sh /etc/init.d/kaltura_batch
		service kaltura_batch start >> $logfile 2>&1
		chkconfig kaltura_batch on
		# Change the batch ID
		printf "Enter a new batch ID ($batch_id)"
		read answer
		if [ ! -z $answer ];then	
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
	if [ $red5_status == "yes" ];then
		service red5 stop >> $logfile 2>&1
		chkconfig red5 off
		rm -f /etc/init.d/red5
	else
		ln -s $base_dir/bin/red5/red5 /etc/init.d/red5
		service red5 start >> $logfile 2>&1
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
	if [ $httpd_status == "yes" ];then
		service httpd stop >> $logfile 2>&1
		chkconfig httpd off
		rm -f /etc/httpd/conf.d/kaltura.conf
		rm -f /etc/cron.d/cleanup
		rm -f /etc/cron.d/api
	else
		ln -s $base_dir/app/configurations/apache/kaltura.conf /etc/httpd/conf.d/kaltura.conf
		ln -s $base_dir/app/configurations/cron/api /etc/cron.d/api
		ln -s $base_dir/app/configurations/cron/cleanup /etc/cron.d/cleanup	
		service httpd start >> $logfile 2>&1
		chkconfig httpd on
	fi
}

# Both files must be present or DWH is assumed to be off
check_dwh(){
	if [ -f /etc/cron.d/dwh ] ;then
		dwh_status=yes
	else
		dwh_status=no
	fi
}

set_dwh(){
	if [ $dwh_status == "no" ];then
		ln -s $base_dir/app/configurations/cron/dwh /etc/cron.d/dwh
	else 
		rm -f /etc/cron.d/dwh
	fi
}
check_admin(){
	if [ -f $base_dir/app/configurations/apache/conf.d/enabled.admin.conf ];then
		admin_status=yes
	else
		admin_status=no
	fi
}
set_admin(){
	if [ $admin_status == "no" ];then
		ln -s $base_dir/app/configurations/apache/conf.d/admin.conf $base_dir/app/configurations/apache/conf.d/enabled.admin.conf
		service httpd reload
	else
		rm  -r $base_dir/app/configurations/apache/conf.d/enabled.admin.conf
		service httpd reload
	fi
}

while :
do
	# Check the status of each component
	for var in  check_batch check_sphinx check_red5 check_httpd check_dwh check_admin;do
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
(6) Admin Console: $admin_status
(0) Quit\

EOL

# I don't like switch, that's why it's this way
	read answer
	if [ ! -z $answer ];then
		if [ $answer -eq 1 ];then
				set_batch
		elif [ $answer -eq 2 ];then 
			set_sphinx
		elif [ $answer -eq 3 ];then
			set_red5
		elif [ $answer -eq 4 ];then
			set_httpd
		elif [ $answer -eq 5 ];then
			set_dwh
		elif [ $answer -eq 6 ];then
			echo "this is not functional at the moment"
		elif [ $answer -eq 0 ];then
			exit 0
		else 
			printf "Invalid option\n"
		fi
	fi
done
