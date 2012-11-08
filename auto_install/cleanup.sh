#!/bin/sh

cat << EOF
Please select the uninstall option:
1. Remove Kaltura and modifications that were done to services(Apache, MySQL, PHP, Memcache) during the install. Packages will NOT be removed. (Recommended on servers that are doing other things.)
2. Remove Kaltura and all related services(Apache, MySQL, PHP, Memcache). Packages WILL be removed. Use this to bring the server back to near distribution clean.
EOF
read CHOICE

if [ "$CHOICE" = '1' ];then

	echo "You selected option 1. Proceed? [y/N]"
	read YESNO
	if [ "$YESNO" = 'y' ];then
			echo "Continuing..."
			service sphinx_watch.sh stop
			service serviceBatchMgr.sh stop
			service red5 stop
			rm -rf /etc/httpd/conf.d/my_kaltura.conf
			
			service mysqld stop
			rm -rf /var/lib/mysql/kaltura*
			sed -i '/lower_case_table_names = 1/d' /etc/my.cnf
            /etc/init.d/mysqld start
		
			if [ -d /etc/php.d ];then
					rm -rf /etc/php.d/kaltura.ini
			else
					INI_FILE=/etc/php.ini
					sed -i 's/request_order = "CGP"/request_order = "GP"/' $INI_FILE
					sed -i 's/upload_tmp_dir*.*web\/tmp//g' $INI_FILE
			fi
			
		
			rm -rf /etc/cron.d/kaltura_crontab
			rm -rf /etc/cron.d/dwh_crontab
			chkconfig --del sphinx_watch.sh
			chkconfig --del red5
			rm -rf /etc/init.d/sphinx_watch.sh
			rm -rf /etc/init.d/serviceBatchMgr.sh
			rm -rf /etc/init.d/red5
			rm -rf /opt/kaltura/
			rm -rf /usr/local/pentaho/
			service httpd stop
			userdel kaltura
			service httpd start
			

	else
			echo "Aborted"
	fi
fi

if [ "$CHOICE" = '2' ];then
	echo "You selected option 2, the dangerous option. Proceed? [y/N]"
	read YESNO
	if [ "$YESNO" = 'y' ];then
		echo "Continuing..."
        service sphinx_watch.sh stop
        service serviceBatchMgr.sh stop
        service red5 stop
		service mysqld stop
		service httpd stop
        yum remove -y httpd* mysql* memcached php*
        rm -rf /etc/httpd/
        rm -rf /var/lib/mysql/
        rm -rf /etc/my.cnf
        rm -rf /etc/php.ini
        rm -rf /etc/php.d/
		chkconfig --del sphinx_watch.sh
		chkconfig --del red5
        rm -rf /etc/cron.d/kaltura_crontab
        rm -rf /etc/cron.d/dwh_crontab
        rm -rf /etc/init.d/sphinx_watch.sh
        rm -rf /etc/init.d/serviceBatchMgr.sh
        rm -rf /opt/kaltura/
        userdel mysql
        userdel apache
        userdel memcached
        userdel kaltura
        rm -rf /usr/local/pentaho/
	else
			echo "Aborted"
	fi
fi