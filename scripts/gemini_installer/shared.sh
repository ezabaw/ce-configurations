#!/bin/bash

read -p "This script is used to setup servers that use the on-prem shared kaltura directory setup THIS SCRIPT HAS NOT BEEN TESTED YET"


# Stop services if started, services may not exist yet on servers that have yet to be configured
service kaltura_batch stop
service kaltura_populate stop
service kaltura_sphinx stop
service httpd stop
service red5 stop

# Install apache if desired
printf  "Will this be an API server? (y/n)\n"
read answer
if [ $answer == 'y' ];then
	yum -y install apache;
fi


# Configure the users to match and use the shared system

#TODO this section will have to add the kaltura user with the UID 
# that matches the other systems


# Backup of important configuration files
mv /opt/kaltura/app/configuration/batch/scheduler.conf /opt/kaltura/app/configuration/batch/scheduler.original
mv /opt/kaltura/app/configuration/batch/`hostname`.ini /opt/kaltura/app/configuration/batch/batch.original

# Server side links
ln -s /opt/kaltura_local/log /opt/kaltura/log
ln -s /opt/kaltura_local/batch.ini /opt/kaltura/app/configurations/batch/batch.ini
ln -s /opt/kaltura_local/scheduler.conf /opt/kaltura/app/configurations/batch/scheduler.ini
ln -s /opt/kaltura_local/scheduler.conf /opt/kaltura/app/configurations/batch/scheduler.conf
rm -rf /opt/kaltura/app/cache
ln -s /opt/kaltura_local/appcache /opt/kaltura/app/cache


# Service links
ln -s /opt/kaltura/app/scripts/kaltura_monit.sh /etc/init.d/kaltura_monit
ln -s /opt/kaltura/app/scripts/kaltura_sphinx.sh /etc/init.d/kaltura_sphinx
ln -s /opt/kaltura/app/scripts/kaltura_populate.sh /etc/init.d/kaltura_populate
ln -s /opt/kaltura/app/scripts/kaltura_batch.sh /etc/init.d/kaltura_batch
ln -s /opt/kaltura/bin/red5/red5 /etc/init.d/red5
ln -s /opt/kaltura/app/configurations/apache/kaltura.conf /etc/httpd/conf.d
ln -s /opt/kaltura/app/configurations/cron/cleanup /etc/cron.d/cleanup
ln -s /opt/kaltura/app/configurations/cron/dwh /etc/cron.d/dwh
ln -s /opt/kaltura/app/configurations/cron/api /etc/cron.d/api
ln -s /opt/kaltura/app/configurations/logrotate/kaltura_base /etc/logrotate.d/kaltura_base
ln -s /opt/kaltura/app/configurations/logrotate/kaltura_sphinx /etc/logrotate.d/kaltura_sphinx
ln -s /opt/kaltura/app/configurations/logrotate/kaltura_cleanup /etc/logrotate.d/kaltura_cleanup
ln -s /opt/kaltura/app/configurations/logrotate/kaltura_populate /etc/logrotate.d/kaltura_populate
ln -s /opt/kaltura/app/configurations/logrotate/kaltura_api /etc/logrotate.d/kaltura_api
ln -s /opt/kaltura/app/configurations/logrotate/kaltura_batch /etc/logrotate.d/kaltura_batch
ln -s /opt/kaltura/app/configurations/logrotate/kaltura_apache /etc/logrotate.d/kaltura_apache
ln -s /opt/kaltura/app/configurations/logrotate/kaltura_apps /etc/logrotate.d/kaltura_apps
mkdir /etc/kaltura.d
ln -s /opt/kaltura/app/configurations/system.ini /etc/kaltura.d/system.ini

# Local directories
mkdir -p /opt/kaltura_local/log
mkdir -p /opt/kaltura_local/log/batch
mkdir -p /opt/kaltura_local/log/sphinx
mkdir -p /opt/kaltura_local/appcache

# Copy templates to local files
cp /opt/kaltura/app/configurations/batch/batch.original /opt/kaltura_local/batch.ini
cp /opt/kaltura/app/configurations/batch/scheduler.original /opt/kaltura_local/scheduler.conf

# Fix permissions
chown -R kaltura:kaltura /opt/kaltura_local
chmod 775 /opt/kaltura_local
find /opt/kaltura_local -type d -exec chmod 775 {} \;

# Services
chkconfig kaltura_batch on
chkconfig kaltura_populate on
chkconfig kaltura_sphinx on
chkconfig httpd on
chkconfig red5 on
chkconfig kaltura_monit off
service kaltura_batch start
service kaltura_populate start
service kaltura_sphinx start
service httpd start
service red5 start
service kaltura_monit stop


