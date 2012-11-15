#!/bin/sh

cat << EOF
Please select the uninstall option
1. Remove Kaltura and modifications that were done to services(Apache, MySQL, PHP, Memcache) during the install. Packages will NOT be removed. (Recommended on servers that are doing other things.)
2. Remove Kaltura and all related services(Apache, MySQL, PHP, Memcache). Packages WILL be removed. Use this to bring the server back to near distribution clean.
3. Remove Kaltura and all related services EXCEPT MySQL and the data. This is good if you want to re-configure the server but keep data intact.
EOF

read CHOICE

if [ "$CHOICE" = "1" ];then

        echo "You selected option 1. Proceed? [y/N]"
        read YESNO
        if [ "$YESNO" = "y" ];then
                        echo "Continuing..."
			for i in sphinx_watch.sh serviceBatchMgr.sh red5;do
				if [ -f /etc/init.d/$i -o -h /etc/init.d/$i ];then
					service $i stop
                                	chkconfig $i off
                                	chkconfig --del $i
					rm -rf /etc/init.d/$i
					echo "Removed /etc/init.d/$i"
				fi
			done
                        
			service mysqld stop
                        rm -rf /var/lib/mysql/kaltura*
			echo "Removed Kaltura Mysql DBs"
                        sed -i '/lower_case_table_names = 1/d' /etc/my.cnf
                        service mysqld start

                        if [ -d /etc/php.d ];then
                                        rm -rf /etc/php.d/kaltura.ini
					echo "Removed php kaltura.ini"
                        else
                                        INI_FILE="/etc/php.ini"
                                        sed -i 's/request_order = "CGP"/request_order = "GP"/' $INI_FILE
                                        sed -i 's/upload_tmp_dir*.*web\/tmp//g' $INI_FILE
                        fi

			for i in /etc/cron.d/kaltura_crontab /etc/cron.d/dwh_crontab /opt/kaltura/ /usr/local/pentaho/ /etc/httpd/conf.d/my_kaltura.conf;do
				if [ -f $i -o -h $i ];then
					rm -rf $i
					echo "Removed $i"
				fi
			done
                  	service httpd stop
			pkill -u kaltura
                        userdel kaltura
                        service httpd start


        else
                        echo "Aborted"
        fi
fi

if [ "$CHOICE" = "2" ];then
        echo "You selected option 2, the dangerous option. Proceed? [y/N]"
        read YESNO
        if [ "$YESNO" = "y" ];then
                echo "Continuing..."
		
		for i in sphinx_watch.sh serviceBatchMgr.sh red5 mysqld httpd;do
			service $i stop
		done
                
		yum remove -y httpd* mysql mysql-* memcached php*
		
		for i in /etc/httpd/ /etc/php.d/ /var/lib/mysql/ /opt/kaltura/ /usr/local/pentaho/;do
			if [ -d $i -o -h $i ];then
				rm -rf $i
				echo "Removed $i"
			fi
		done
                
		for i in /etc/my.cnf /etc/php.ini /etc/cron.d/kaltura_crontab /etc/cron.d/dwh_crontab;do
			if [ -f $i -o -h $i ];then
				rm -rf $i
				echo "Removed $i"
			fi
		done
		
		for i in sphinx_watch.sh serviceBatchMgr.sh red5;do
                                if [ -f /etc/init.d/$i -o -h /etc/init.d/$i ];then
					service $i stop
                                	chkconfig $i off
                                	chkconfig --del $i
                                        rm -rf /etc/init.d/$i
					echo "Removed /etc/init.d/$i"
                                fi
                done

		pkill -u kaltura
		for i in mysql apache memcached kaltura;do
			userdel $i
		done
        else
                        echo "Aborted"
        fi
fi

if [ "$CHOICE" = "3" ];then
  	        service sphinx_watch.sh stop
                service serviceBatchMgr.sh stop
                service red5 stop
                service mysqld stop
                service httpd stop
                yum remove -y httpd* memcached php*
                rm -rf /etc/httpd/
                rm -rf /etc/php.ini
                rm -rf /etc/php.d/
                chkconfig --del sphinx_watch.sh
                chkconfig --del red5
                rm -rf /etc/cron.d/kaltura_crontab
                rm -rf /etc/cron.d/dwh_crontab
                rm -rf /etc/init.d/sphinx_watch.sh
                rm -rf /etc/init.d/serviceBatchMgr.sh
                pkill -u kaltura
                rm -rf /opt/kaltura/
                userdel apache
                userdel memcached
                userdel kaltura
                rm -rf /usr/local/pentaho/
fi
