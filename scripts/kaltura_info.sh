#!/bin/bash
#**************************************
#	Kaltura
#**************************************


# This script provides basic information about a kaltura installation

# Usage
if [ $# -ne 2 ];then
	echo -e "Usage: $0 -s <kaltura_directory>\n"
	exit 1
fi

# This function extracts the value of a parameter in the style of variable = parameter, it also makes the output nicer by removing quotes, commas and a space
pextract () {
returnval=$(echo $@  | awk 'BEGIN { FS="=|=>" } { print $2 }' | tr -d ' |" | ,')
}

# Set the base directory based on input
base_dir=$2
# Determine Kaltura version
if [ -e $base_dir/app/configurations/version.ini ];then
        version=5
else
        version=4
fi

# Gather configuration files
mkdir -p report/kaltura/config
mkdir -p report/etc/sysconfig/network-scripts
if [ $version -eq 5 ];then
	cp -a $base_dir/app/configurations/* report/kaltura/config
elif [ $version -eq 4 ]; then
	mkdir -p report/kaltura/config/api_v3
	mkdir -p report/kaltura/config/batch
	mkdir -p report/kaltura/config/alpha
	mkdir -p report/kaltura/config/admin_console
	cp -a $base_dir/app/api_v3/config/* report/kaltura/config/api_v3/
	cp -a $base_dir/app/batch/*.ini report/kaltura/config/batch/ 
	cp -a $base_dir/app/alpha/config/* report/kaltura/config/alpha/
	cp -a $base_dir/app/admin_console/configs/* report/kaltura/config/admin_console
else
	echo "Version unsupported"	
	exit 1
fi
ps aux >> report/process_report
netstat -anp >> report/network_report

# Copy configuration files to the report directory
cp -a /etc/hosts report/etc/hosts
cp -a /etc/my.cnf report/etc/my.cnf
cp -a /etc/php.ini report/etc/php.ini
cp -aL /etc/php.d report/etc/
mkdir -p report/httpd/
cp -aL /etc/httpd/conf.d report/httpd/conf.d
cp -aL /etc/httpd/conf report/httpd/conf
cp -aL /etc/sysconfig/network report/etc/sysconfig/
cp -aL /etc/sysconfig/network-scripts report/etc/sysconfig/

# System information
mysql_version=$(mysql --version | awk '{ print $5 }' |cut -f 1 -d ',')
apache_version=$(httpd -v | head -n 1| awk '{ print $3 }'|cut -f 2 -d '/')
php_version=$(php -v | head -n 1 | awk '{print $2}')
cpu_cores=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)
cpu_speed=$(grep -m 1 'cpu MHz' /proc/cpuinfo | awk '/^cpu MHz/{print $4}' | cut -f 1 -d'.')
total_memorykb=$(grep 'MemTotal' /proc/meminfo | awk '/^MemTotal/{print $2}')
total_memory=$(expr $total_memorykb / 1024)
free_space=$(df -P | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }')
# Obtains information about the kaltura install
if [ $version -eq 5 ];then
        pextract $(grep -m 1 'settings.serviceUrl' report/kaltura/config/admin.ini)
        serviceUrl=$returnval
        pextract $(grep -m 1 'id' report/kaltura/config/batch.ini)
        batchID=$returnval
        pextract $(grep -m 1 'datasources.propel.connection.user' report/kaltura/config/db.ini)
        dbuser=$returnval
        pextract $(grep -m 1 'datasources.propel.connection.password' report/kaltura/config/db.ini)
        dbpass=$returnval
        pextract $(grep -m 1 'datasources.propel.connection.hostspec' report/kaltura/config/db.ini)
        dbhost=$returnval
		sphinx_host=$(grep 'datasources.sphinx.connection.dsn' report/kaltura/config/db.ini |cut -f 3 -d'='|cut -f 1 -d';')
	
elif [ $version -eq 4 ]; then
	pextract $(grep -m 1 'setting' report/kaltura/config/admin_console/application.ini)
	serviceUrl=$returnval
	pextract $(grep -m 1 'id' report/kaltura/config/batch/batch_config.ini)
	batchID=$returnval
	dbuser=$(grep -m 1 "'user'"  report/kaltura/config/alpha/kConfLocal.php \
	| awk '{print $3}' | cut -f 2 -d"'")
	dbpass=$(grep -m 1 "'password'" report/kaltura/config/alpha/kConfLocal.php \
       	| awk '{print $3}' | cut -f 2 -d"'")
	dbhost=$(grep -m 1 "'hostspec'" report/kaltura/config/alpha/kConfLocal.php \
       	| awk '{print $3}' | cut -f 2 -d"'")
	sphinx_host=$(grep  -o -m 1 -A 5 "mysql:host=.*\;port=" report/kaltura/config/alpha/kConfLocal.php  | awk -F '(mysql:host=|;port=)' '{print $2}')	
else
        echo "Version Unsupported"
        exit 1
fi

# Timezone checks
# PHP ini timezone is version independent
pextract $(grep -i '^date.timezone' /etc/php.ini)
php_timezone=$returnval

if [ $version -eq 5 ];then
	pextract $(grep -i '^date_default_timezone' $base_dir/app/configurations/local.ini)
	kaltura_timezone=$returnval
	pextract $(grep '^DataTimeZone' $base_dir/dwh/.kettle/kettle.properties)
	kettle_timezone=$returnval
	
	
elif [ $version -eq 4 ];then
	pextract $(grep -i 'date_default_timezone' $base_dir/app/alpha/config/kConfLocal.php)
	kaltura_timezone=$returnval
	pextract $(grep '^DataTimeZone' $base_dir/dwh/.kettle/kettle.properties)
	kettle_timezone=$returnval
else
	echo "Version Unsupported"
	exit 1
fi
cat > report/system_report <<EOL
----------------------------------------------
Kaltura Installation Report Tool
----------------------------------------------
Processor(s): ${cpu_speed}Mhz x $cpu_cores cores  Memory: ${total_memory}MB
Status:$(uptime)
Hostname: $(hostname)
Free Space:
${free_space}

Kaltura Version: $version
Kaltura Base Directory: $base_dir
Kaltura Log Size: $(du -sh $base_dir/log | awk {'print $1'})
Kaltura Web Log Size: $(du -sh $base_dir/web/logs 2> /dev/null| awk '{print $1}')
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

# Check if you can connect to the database
echo -n "MySQL Connection: " >> report/system_report

if mysql -u $dbuser -p$dbpass -h $dbhost <<< "quit" &> /dev/null ;then
	echo -e "\033[32mSuccessful \033[0m" >> report/system_report
else
	echo -e "\033[31mFailed \033[0m" >> report/system_report
fi
#Sphinx Check
echo -n "Sphinx Connection: " >> report/system_report
if nc -z -w 2 $sphinx_host 9312 &> /dev/null ;then
	echo -e "\033[32mSuccessful \033[0m" >> report/system_report
else
	echo -e "\033[31mFailed \033[0m" >> report/system_report
fi
# Basic API check
echo -n "API Connection: " >> report/system_report
api_test=$(wget -qO- --tries=1 --timeout=10 'http://localhost/api_v3/?service=system&action=ping' | awk  -F '(<result>|</result>)' '{print $2}')
if [ -z "$api_test" ] || [ "$api_test" != "1" ];then
	echo -e "\033[31mFailed \033[0m" >> report/system_report
else
	echo -e "\033[32mSuccessful\033[0m" >> report/system_report
fi

# Check if services are running, new services can be listed here but they must 
# be matchable through pgrep
echo -n "Services: " >> report/system_report
for x in searchd httpd mysqld memcached KGenericBatchMgr ntp;do
        if pgrep -of $x >> /dev/null;then
                echo -ne "\033[32m${x} \033[0m" >> report/system_report
        else
                echo -ne "\033[31m${x} \033[0m" >> report/system_report
        fi
done

# Software versions
echo -e "\nPHP $php_version Apache $apache_version MySQL $mysql_version\n" >> report/system_report

# Print the report
cat report/system_report

# MD5 work in progress
if [ $1 = "-m" ];then
	echo -e "$(date) Performing checksum of the kaltura directory" | tee -a report/md5sum
	find $base_dir -type f \
       		! -wholename '*/entry/*' \
      		! -wholename '*/web/logs/*' \
      	 	! -wholename '*/log/*' \
	       -exec md5sum {} >> report/md5sum 2> /dev/null \;
	echo "$(date) Checksum complete" | tee -a report/md5sum
fi
exit 0
