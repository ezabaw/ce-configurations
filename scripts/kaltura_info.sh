#!/bin/bash
#**************************************
#	Kaltura
#**************************************
# This script provides basic information about a kaltura installation
# todo: combine version specific tasks to one section
# general cleanup
# convert to printf so I look cool in the bash scene
usage () {
	echo -e "Usage: $0 -b <kaltura_directory>"
		
}

while :
do
    case $1 in
        -h | --help | -\?)
            usage
			exit 0
			;;
		-b | --basedir)
			base_dir=$2
			shift 2
			;;
        *)  
            break
            ;;
    esac
done

# Base directory
if [ -z $base_dir ];then
	echo "Base directory not specificed assuming /opt/kaltura"
	base_dir="/opt/kaltura"
fi

# Formatted execution date of this software
exe_time=$(date +%d-%m-%Y-%k-%M-%S)

# Report directory
report_dir=/tmp/kaltura_info_$exe_time
mkdir -p $report_dir
report_file=$report_dir/kaltura_report.txt

# Required programs
if  ! which nc &> /dev/null ;then
	echo -e "\033[31m****************************\033[0m"
	echo -e "\033[31mNC is required to check for connectivity, results may not be accurate\033[0m"
	echo -e "\033[31m****************************\033[0m"
fi


# Utility functions, useful to extract parameters from the kaltura variables
pextract () {
	returnval=$(echo $@  | awk 'BEGIN { FS="=|=>" } { print $2 }' | tr -d ' |" | ,')
}

# Determine Kaltura version, this needs to be changed to something better, however they only started versions in 5 and accidentally
# left that out in version 6.1 : ' (
if [ -e $base_dir/app/configurations/version.ini ];then
        version=6
        echo "Kaltura Falcon(2) Detected"
else
        version=5
        echo "Kaltura Eagle Detected"
fi

# System information
mysql_version=$(mysql --version | awk '{ print $5 }' |cut -f 1 -d ',')
apache_version=$(httpd -v | head -n 1| awk '{ print $3 }'|cut -f 2 -d '/')
php_version=$(php -v | head -n 1 | awk '{print $2}')
cpu_cores=$(cat /proc/cpuinfo | awk '/^processor/{print $report_dir}' | wc -l)
cpu_speed=$(grep -m 1 'cpu MHz' /proc/cpuinfo | awk '/^cpu MHz/{print $4}' | cut -f 1 -d'.')
total_memorykb=$(grep 'MemTotal' /proc/meminfo | awk '/^MemTotal/{print $2}')
total_memory=$(expr $total_memorykb / 1024)
free_space=$(df -P | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }')
free_inodes=$(df -iP | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }')
ips=$(ifconfig | grep -oP 'inet addr:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
pextract $(grep -i '^date.timezone' /etc/php.ini)
php_timezone=$returnval

# System information to the report directory
cp /etc/my.cnf $report_dir/my.cnf
cp $(php -i |grep '^Loaded Configuration File' | awk '{print $5}') $report_dir/php.ini
cp -a /etc/httpd/conf $report_dir/apache_conf
cp -a /etc/httpd/conf.d $report_dir/apache_conf.d
ifconfig > $report_dir/ifconfig
cp /etc/resolv.conf  $report_dir/resolv.conf
free > $report_dir/free_mem
ps aux > $report_dir/ps
top -n 1 > $report_dir/top

# Kaltura information
if [ $version -eq 6 ];then
    # Extract information for the visual report
	pextract $(grep -m 1 'settings.serviceUrl' $base_dir/app/configurations/admin.ini)
    serviceUrl=$returnval
    pextract $(grep -m 1 'id' $base_dir/app/configurations/admin.ini)
	batchID=$returnval
	pextract $(grep -m 1 'datasources.propel.connection.user' $base_dir/app/configurations/db.ini)
	dbuser=$returnval
	pextract $(grep -m 1 'datasources.propel.connection.password' $base_dir/app/configurations/db.ini)
	dbpass=$returnval
	pextract $(grep -m 1 'datasources.propel.connection.hostspec' $base_dir/app/configurations/db.ini)
	dbhost=$returnval
	sphinx_host=$(grep 'datasources.sphinx.connection.dsn' $base_dir/app/configurations/db.ini |cut -f 3 -d'='|cut -f 1 -d';')
	pextract $(grep -i '^date_default_timezone' $base_dir/app/configurations/local.ini)
	kaltura_timezone=$returnval
	pextract $(grep '^DataTimeZone' $base_dir/dwh/.kettle/kettle.properties)
	kettle_timezone=$returnval
	# Copy configuration files
	cp -a $base_dir/app/configurations $report_dir
	cp -a $base_dir/dwh/.kettle/kettle.properties $report_dir/kettle.properties
	
	
elif [ $version -eq 5 ]; then
	pextract $(grep -m 1 'setting' $base_dir/app/admin_console/configs/application.ini)
	serviceUrl=$returnval
	pextract $(grep -m 1 'id' $base_dir/app/batch/batch_config.ini)
	batchID=$returnval
	dbuser=$(grep -m 1 "'user'"  $base_dir/app/alpha/config/kConfLocal.php \
	| awk '{print $3}' | cut -f 2 -d"'")
	dbpass=$(grep -m 1 "'password'" $base_dir/app/alpha/config/kConfLocal.php \
       	| awk '{print $3}' | cut -f 2 -d"'")
	dbhost=$(grep -m 1 "'hostspec'" $base_dir/app/alpha/config/kConfLocal.php \
       	| awk '{print $3}' | cut -f 2 -d"'")
	sphinx_host=$(grep  -o -m 1 -A 5 "mysql:host=.*\;port=" $base_dir/app/alpha/config/kConfLocal.php  | awk -F '(mysql:host=|;port=)' '{print $2}')
	pextract $(grep -i 'date_default_timezone' $base_dir/app/alpha/config/kConfLocal.php)
	kaltura_timezone=$returnval
	pextract $(grep '^DataTimeZone' $base_dir/dwh/.kettle/kettle.properties)
	kettle_timezone=$returnval
	# Copy configuration files
	cp $base_dir/app/admin_console/configs $report_dir/admin_configs
	cp $base_dir/app/batch/batch_config.ini $report_dir
	cp $base_dir/app/alpha/config $report_dir/alpha_configs
	cp $base_dir/dwh/.kettle/kettle.properties $report_dir/kettle.properties
else
        echo "Version Unsupported"
        exit 1
fi

# Report generation
cat > $report_file <<EOL
----------------------------------------------
Kaltura Installation Report Tool


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

$ips
MySQL User: $dbuser Password: $dbpass
MySQL Host: $dbhost
Sphinx Host: $sphinx_host

Time zones:
PHP: $php_timezone
 Kaltura: $kaltura_timezone 
 Kettle: $kettle_timezone
EOL

# Time check
if ntpstat &> /dev/null ;then
	echo "The NTP server is functioning properly, clock syncronized" >> $report_file
else
	echo "There is a problem with the NTP server" >> $report_file
fi
# MySQL connection check
echo -en "\nMySQL Connection: " >> $report_file

if mysql -u $dbuser -p$dbpass -h $dbhost <<< "quit" &> /dev/null ;then
	echo -e "\033[32mSuccessful \033[0m" >> $report_file
else
	echo -e "\033[31mFailed \033[0m" >> $report_file
fi

# Sphinx connection check
echo -n "Sphinx Connection: " >> $report_file
if nc -z -w 2 $sphinx_host 9312 &> /dev/null ;then
	echo -e "\033[32mSuccessful \033[0m" >> $report_file
else
	echo -e "\033[31mFailed \033[0m" >> $report_file
fi

# Basic API check, the local connection is made to the current machine, whereas the remote
# connection is the configuraitons service url, the local machine may not be acting as an API
# server
echo -n "Local API Connection: " >> $report_file
api_test=$(wget -qO- --tries=1 --timeout=10 'http://localhost/api_v3/?service=system&action=ping' | awk  -F '(<result>|</result>)' '{print $2}')
if [ -z "$api_test" ] || [ "$api_test" != "1" ];then
	echo -e "\033[31mFailed \033[0m" >> $report_file
else
	echo -e "\033[32mSuccessful\033[0m" >> $report_file
fi
echo -n "Remote API Connection: " >> $report_file
remote_api_test=$(wget -qO- --tries=1 --timeout=10 "${serviceUrl}/api_v3/?service=system&action=ping" | awk  -F '(<result>|</result>)' '{print $2}')
if [ -z "$api_test" ] || [ "$api_test" != "1" ];then
	echo -e "\033[31mFailed \033[0m" >> $report_file
else
	echo -e "\033[32mSuccessful\033[0m" >> $report_file
fi

# Check if services are running
echo -n "Services: " >> $report_file
for x in searchd httpd mysqld memcached KGenericBatchMgr ntp;do
        if pgrep -of $x >> /dev/null;then
                echo -ne "\033[32m${x} \033[0m" >> $report_file
        else
                echo -ne "\033[31m${x} \033[0m" >> $report_file
        fi
done

# Software versions
echo -e "\n\nPHP $php_version Apache $apache_version MySQL $mysql_version" >> $report_file

# Log status
echo -e "\n Log status" >> $report_file
if [ $version -eq 6 ];then
	grep -H '^[^;]*priority \?= \?[0-9]' /opt/kaltura/app/configurations/logger.ini >> $report_file
else 
	grep -H '^[^;]*priority \?= \?[0-9]' /opt/kaltura/app/batch/logger.ini /opt/kaltura/app/api_v3/config/logger.ini >> $report_file
fi
# Output report
cat $report_file

# Permissions check
echo -e "\nPerforming permissions check"
apache_user=$(ps auxw | grep http | grep -m 1 -v root |awk '{print $1}')
apache_group=$(ps augxw | grep http | grep -m 1 -v root | awk '{print $2}')
while read -r -d ' ' user && read -r -d ' ' group && read -r -d ' ' permissions && IFS='' read -r -d '' filename; do
if [ $apache_user == $user ];then
	if [ ${permissions:0:1} -lt 6 ];then
		echo "Bad permissions on $filename $(ls $filename -l |awk '{print $1" "$3" "$4}')"
	fi
elif [ $apache_group == $group ];then
	if [ ${permissions:1:1} -lt 6 ];then
		echo "Bad permissions on $filename $(ls $filename -l |awk '{print $1" "$3" "$4}')" 
	fi
elif [ ${permissions:2:1} -lt 6 ];then
	echo "Bad permissions on $filename $(ls $filename -l |awk '{print $1" "$3" "$4}')" 

else
	:
fi
done < <(find $base_dir -type f -printf '%u %g %m %p\0') > $report_dir/permissions

# Tar up the directory and notify the user of it's location
tar -zcf /tmp/kaltura_info_$exe_time.tar.gz $report_dir &> /dev/null
echo "Kaltura report is located at /tmp/kaltura_info_${exe_time}.tar.gz"


exit 0
