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


if [ -z $base_dir ];then
	echo "Base directory not specificed assuming /opt/kaltura"
	base_dir="/opt/kaltura"
fi

# Utility functions, useful to extract parameters from the kaltura variables
pextract () {
	returnval=$(echo $@  | awk 'BEGIN { FS="=|=>" } { print $2 }' | tr -d ' |" | ,')
}

# Determine Kaltura version, this needs to be changed to something better
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
# php timezone
pextract $(grep -i '^date.timezone' /etc/php.ini)
php_timezone=$returnval

# Kaltura information
if [ $version -eq 6 ];then
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
	# Kaltura timezone
	pextract $(grep -i '^date_default_timezone' $base_dir/app/configurations/local.ini)
	kaltura_timezone=$returnval
	# Kettle timezone
	pextract $(grep '^DataTimeZone' $base_dir/dwh/.kettle/kettle.properties)
	kettle_timezone=$returnval
elif [ $version -eq 5 ]; then
	pextract $(grep -m 1 'setting' $base_dir/app/config/admin_console/application.ini)
	serviceUrl=$returnval
	pextract $(grep -m 1 'id' $base_dir/app/batch/batch_config.ini)
	batchID=$returnval
	dbuser=$(grep -m 1 "'user'"  $base_dir/app/api_v3/config/alpha/kConfLocal.php \
	| awk '{print $3}' | cut -f 2 -d"'")
	dbpass=$(grep -m 1 "'password'" /app/api_v3/app/alpha/config/kConfLocal.php \
       	| awk '{print $3}' | cut -f 2 -d"'")
	dbhost=$(grep -m 1 "'hostspec'" $base_dir/app/alpha/config/kConfLocal.php \
       	| awk '{print $3}' | cut -f 2 -d"'")
	sphinx_host=$(grep  -o -m 1 -A 5 "mysql:host=.*\;port=" $base_dir/app/alpha/config/kConfLocal.php  | awk -F '(mysql:host=|;port=)' '{print $2}')
	pextract $(grep -i 'date_default_timezone' $base_dir/app/alpha/config/kConfLocal.php)
	kaltura_timezone=$returnval
	pextract $(grep '^DataTimeZone' $base_dir/dwh/.kettle/kettle.properties)
	kettle_timezone=$returnval	
else
        echo "Version Unsupported"
        exit 1
fi

# Report generation
cat > /tmp/ksystem_report <<EOL
----------------------------------------------
Kaltura Installation Report Tool
$(date)

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
	echo "The NTP server is functioning properly, clock syncronized" >> /tmp/ksystem_report
else
	echo "There is a problem with the NTP server" >> /tmp/ksystem_report
fi
# MySQL connection check
echo -en "\nMySQL Connection: " >> /tmp/ksystem_report

if mysql -u $dbuser -p$dbpass -h $dbhost <<< "quit" &> /dev/null ;then
	echo -e "\033[32mSuccessful \033[0m" >> /tmp/ksystem_report
else
	echo -e "\033[31mFailed \033[0m" >> /tmp/ksystem_report
fi

# Sphinx connection check
echo -n "Sphinx Connection: " >> /tmp/ksystem_report
if nc -z -w 2 $sphinx_host 9312 &> /dev/null ;then
	echo -e "\033[32mSuccessful \033[0m" >> /tmp/ksystem_report
else
	echo -e "\033[31mFailed \033[0m" >> /tmp/ksystem_report
fi

# Basic API check, the local connection is made to the current machine, whereas the remote
# connection is the configuraitons service url, the local machine may not be acting as an API
# server
echo -n "Local API Connection: " >> /tmp/ksystem_report
api_test=$(wget -qO- --tries=1 --timeout=10 'http://localhost/api_v3/?service=system&action=ping' | awk  -F '(<result>|</result>)' '{print $2}')
if [ -z "$api_test" ] || [ "$api_test" != "1" ];then
	echo -e "\033[31mFailed \033[0m" >> /tmp/ksystem_report
else
	echo -e "\033[32mSuccessful\033[0m" >> /tmp/ksystem_report
fi
echo -n "Remote API Connection: " >> /tmp/ksystem_report
remote_api_test=$(wget -qO- --tries=1 --timeout=10 "${serviceUrl}/api_v3/?service=system&action=ping" | awk  -F '(<result>|</result>)' '{print $2}')
if [ -z "$api_test" ] || [ "$api_test" != "1" ];then
	echo -e "\033[31mFailed \033[0m" >> /tmp/ksystem_report
else
	echo -e "\033[32mSuccessful\033[0m" >> /tmp/ksystem_report
fi

# Check if services are running
echo -n "Services: " >> /tmp/ksystem_report
for x in searchd httpd mysqld memcached KGenericBatchMgr ntp;do
        if pgrep -of $x >> /dev/null;then
                echo -ne "\033[32m${x} \033[0m" >> /tmp/ksystem_report
        else
                echo -ne "\033[31m${x} \033[0m" >> /tmp/ksystem_report
        fi
done

# Test NTP



# Software versions
echo -e "\n\nPHP $php_version Apache $apache_version MySQL $mysql_version" >> /tmp/ksystem_report

# Log status
echo -e "\n Log status" >> /tmp/ksystem_report
if [ $version -eq 6 ];then
	grep -H '^[^;]*priority \?= \?[0-9]' /opt/kaltura/app/configurations/logger.ini >> /tmp/ksystem_report
else 
	grep -H '^[^;]*priority \?= \?[0-9]' /opt/kaltura/app/batch/logger.ini /opt/kaltura/app/api_v3/config/logger.ini >> /tmp/ksystem_report
fi
# Output report
cat /tmp/ksystem_report


exit 0
