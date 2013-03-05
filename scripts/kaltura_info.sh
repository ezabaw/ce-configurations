#!/bin/bash -x
#**************************************
#	Kaltura
#**************************************
# This script provides basic information about a kaltura installation
usage () {
	echo -e "Usage: $0 -s <kaltura_directory> -o <report_output_directory>
			Optional: -c  performs md5 checksum as part of the report
			-m <email> sends out the report to the supplied email address\n"
}

while :
do
    case $1 in
        -h | --help | -\?)
            usage
			exit 0
			;;
		-s | --basedir)
			base_dir=$2
			shift 2
			;;
		-o | --reportdir)
			report_dir=$2
			shift 2
			;;
		-m | --mail)
			report_email=$2
			shift 2
			;;
		-c	| --checksum)
			checksum=1
			shift
			;;
        *)  
            break
            ;;
    esac
done

# required paramters
if [ -z $report_dir ];then
	echo "Missing output directory"
	usage
	exit 1
fi
if [ -z $base_dir ];then
	echo "Missing base directory"
	usage
	exit 1
fi

# Utility functions
pextract () {
	returnval=$(echo $@  | awk 'BEGIN { FS="=|=>" } { print $2 }' | tr -d ' |" | ,')
}



# Determine Kaltura version
if [ -e $base_dir/app/configurations/version.ini ];then
        version=5
else
        version=4
fi

# Gather configuration files
mkdir -p report_dir/kaltura/config
mkdir -p report_dir/etc/sysconfig/network-scripts
if [ $version -eq 5 ];then
	cp -a $base_dir/app/configurations/* report_dir/kaltura/config
elif [ $version -eq 4 ]; then
	mkdir -p report_dir/kaltura/config/api_v3
	mkdir -p report_dir/kaltura/config/batch
	mkdir -p report_dir/kaltura/config/alpha
	mkdir -p report_dir/kaltura/config/admin_console
	cp -a $base_dir/app/api_v3/config/* report_dir/kaltura/config/api_v3/
	cp -a $base_dir/app/batch/*.ini report_dir/kaltura/config/batch/ 
	cp -a $base_dir/app/alpha/config/* report_dir/kaltura/config/alpha/
	cp -a $base_dir/app/admin_console/configs/* report_dir/kaltura/config/admin_console
else
	echo "Version unsupported"	
	exit 1
fi
ps aux >> report_dir/process_report
netstat -anp >> report_dir/network_report

# Copy configuration files to the report directory
cp -a /etc/hosts report_dir/etc/hosts
cp -a /etc/my.cnf report_dir/etc/my.cnf
cp -a /etc/php.ini report_dir/etc/php.ini
cp -aL /etc/php.d report_dir/etc/
mkdir -p report_dir/httpd/
cp -aL /etc/httpd/conf.d report_dir/httpd/conf.d
cp -aL /etc/httpd/conf report_dir/httpd/conf
cp -aL /etc/sysconfig/network report_dir/etc/sysconfig/
cp -aL /etc/sysconfig/network-scripts report_dir/etc/sysconfig/

# System information
mysql_version=$(mysql --version | awk '{ print $5 }' |cut -f 1 -d ',')
apache_version=$(httpd -v | head -n 1| awk '{ print $3 }'|cut -f 2 -d '/')
php_version=$(php -v | head -n 1 | awk '{print $2}')
cpu_cores=$(cat /proc/cpuinfo | awk '/^processor/{print report_dir}' | wc -l)
cpu_speed=$(grep -m 1 'cpu MHz' /proc/cpuinfo | awk '/^cpu MHz/{print $4}' | cut -f 1 -d'.')
total_memorykb=$(grep 'MemTotal' /proc/meminfo | awk '/^MemTotal/{print $2}')
total_memory=$(expr $total_memorykb / 1024)
free_space=$(df -P | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }')
free_inodes=$(df -iP | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }')
pextract $(grep -i '^date.timezone' /etc/php.ini)
php_timezone=$returnval

# Kaltura information
if [ $version -eq 5 ];then
    pextract $(grep -m 1 'settings.serviceUrl' report_dir/kaltura/config/admin.ini)
    serviceUrl=$returnval
    pextract $(grep -m 1 'id' report_dir/kaltura/config/batch.ini)
	batchID=$returnval
	pextract $(grep -m 1 'datasources.propel.connection.user' report_dir/kaltura/config/db.ini)
	dbuser=$returnval
	pextract $(grep -m 1 'datasources.propel.connection.password' report_dir/kaltura/config/db.ini)
	dbpass=$returnval
	pextract $(grep -m 1 'datasources.propel.connection.hostspec' report_dir/kaltura/config/db.ini)
	dbhost=$returnval
	sphinx_host=$(grep 'datasources.sphinx.connection.dsn' report_dir/kaltura/config/db.ini |cut -f 3 -d'='|cut -f 1 -d';')
	pextract $(grep -i '^date_default_timezone' $base_dir/app/configurations/local.ini)
	kaltura_timezone=$returnval
	pextract $(grep '^DataTimeZone' $base_dir/dwh/.kettle/kettle.properties)
	kettle_timezone=$returnval
elif [ $version -eq 4 ]; then
	pextract $(grep -m 1 'setting' report_dir/kaltura/config/admin_console/application.ini)
	serviceUrl=$returnval
	pextract $(grep -m 1 'id' report_dir/kaltura/config/batch/batch_config.ini)
	batchID=$returnval
	dbuser=$(grep -m 1 "'user'"  report_dir/kaltura/config/alpha/kConfLocal.php \
	| awk '{print report_dir}' | cut -f 2 -d"'")
	dbpass=$(grep -m 1 "'password'" report_dir/kaltura/config/alpha/kConfLocal.php \
       	| awk '{print report_dir}' | cut -f 2 -d"'")
	dbhost=$(grep -m 1 "'hostspec'" report_dir/kaltura/config/alpha/kConfLocal.php \
       	| awk '{print report_dir}' | cut -f 2 -d"'")
	sphinx_host=$(grep  -o -m 1 -A 5 "mysql:host=.*\;port=" report_dir/kaltura/config/alpha/kConfLocal.php  | awk -F '(mysql:host=|;port=)' '{print $2}')
	pextract $(grep -i 'date_default_timezone' $base_dir/app/alpha/config/kConfLocal.php)
	kaltura_timezone=$returnval
	pextract $(grep '^DataTimeZone' $base_dir/dwh/.kettle/kettle.properties)
	kettle_timezone=$returnval	
else
        echo "Version Unsupported"
        exit 1
fi

# Report generation
cat > report_dir/system_report <<EOL
----------------------------------------------
Kaltura Installation Report Tool
$(date)
----------------------------------------------
Processor(s): ${cpu_speed}Mhz x $cpu_cores cores  Memory: ${total_memory}MB
Status: $(uptime)
Hostname: $(hostname)
Disk Usage:
$free_space
Inode Usage:
$free_inodes

Kaltura Version: $version
Kaltura Base Directory: $base_dir
Kaltura Log Directory Size: $(du -sh $base_dir/log | awk {'print $1'})
Kaltura Web Log Directory Size: $(du -sh $base_dir/web/logs 2> /dev/null| awk '{print $1}')
Service URL: $serviceUrl
Batch ID: $batchID

MySQL User: $dbuser
MySQL Password: $dbpass
MySQL Host: $dbhost
Sphinx Host: $sphinx_host

Time zones:
PHP: $php_timezone
Kaltura: $kaltura_timezone
Kettle: $kettle_timezone

EOL

# MySQL connection check
echo -n "MySQL Connection: " >> report_dir/system_report

if mysql -u $dbuser -p$dbpass -h $dbhost <<< "quit" &> /dev/null ;then
	echo -e "\033[32mSuccessful \033[0m" >> report_dir/system_report
else
	echo -e "\033[31mFailed \033[0m" >> report_dir/system_report
fi

# Sphinx connection check
echo -n "Sphinx Connection: " >> report_dir/system_report
if nc -z -w 2 $sphinx_host 9312 &> /dev/null ;then
	echo -e "\033[32mSuccessful \033[0m" >> report_dir/system_report
else
	echo -e "\033[31mFailed \033[0m" >> report_dir/system_report
fi

# Basic API check, the local connection is made to the current machine, whereas the remote
# connection is the configuraitons service url
echo -n "Local API Connection: " >> report_dir/system_report
api_test=$(wget -qO- --tries=1 --timeout=10 'http://localhost/api_v3/?service=system&action=ping' | awk  -F '(<result>|</result>)' '{print $2}')
if [ -z "$api_test" ] || [ "$api_test" != "1" ];then
	echo -e "\033[31mFailed \033[0m" >> report_dir/system_report
else
	echo -e "\033[32mSuccessful\033[0m" >> report_dir/system_report
fi
echo -n "Remote API Connection: " >> report_dir/system_report
remote_api_test=$(wget -qO- --tries=1 --timeout=10 "${serviceUrl}/api_v3/?service=system&action=ping" | awk  -F '(<result>|</result>)' '{print $2}')
if [ -z "$api_test" ] || [ "$api_test" != "1" ];then
	echo -e "\033[31mFailed \033[0m" >> report_dir/system_report
else
	echo -e "\033[32mSuccessful\033[0m" >> report_dir/system_report
fi

# Check if services are running
echo -n "Services: " >> report_dir/system_report
for x in searchd httpd mysqld memcached KGenericBatchMgr ntp;do
        if pgrep -of $x >> /dev/null;then
                echo -ne "\033[32m${x} \033[0m" >> report_dir/system_report
        else
                echo -ne "\033[31m${x} \033[0m" >> report_dir/system_report
        fi
done

# Software versions
echo -e "\nPHP $php_version Apache $apache_version MySQL $mysql_version\n" >> report_dir/system_report

# Output report
cat report_dir/system_report

# Mail the report to the report user
if [ ! -z $report_email ];then
	archive_file="/tmp/kaltura_report_$(date +%Y-%m-%d-%H-%M).tar.gz"
	tar czf "$archive_file" "$report_dir" &> /dev/null
	gpg --batch --passphrase kimberbenton -c "$archive_file"
	mailx -s "Kaltura report from $hostname" -a "$archive_file" "$report_email" <<< "Kaltura report from $hostname"
fi
# Perform checksum (todo)
if [ ! -z $checksum ];then
	echo -e "$(date) Performing checksum of the kaltura directory" | tee -a report_dir/md5sum
	find $base_dir -type f \
       		! -wholename '*/entry/*' \
      		! -wholename '*/web/logs/*' \
      	 	! -wholename '*/log/*' \
	       -exec md5sum {} >> report_dir/md5sum 2> /dev/null \;
	echo "$(date) Checksum complete" | tee -a report_dir/md5sum
fi

exit 0
