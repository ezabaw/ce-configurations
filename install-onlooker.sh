#!/bin/sh


if [ -d /opt/kaltura/app/onlooker/ ];then
	
	echo "Onlooker already installed! Check /opt/kaltura/app/onlooker"
	exit
else

	mkdir -p /opt/kaltura/app/onlooker/
	cp -Rp .gitignore /opt/kaltura/app/onlooker/
	cp -Rp * /opt/kaltura/app/onlooker/
	chown -R root.root /opt/kaltura/app/onlooker/
fi

yum install -y git inotify-tools*.rpm
cd /
ln -s /opt/kaltura/app/onlooker/.gitignore .
git init .
git add /


echo 200000 > /proc/sys/fs/inotify/max_user_watches

echo "#Added for kaltura onlooker service" >> /etc/sysctl.conf
echo "fs.inotify.max_user_watches=200000" >> /etc/sysctl.conf

ln -s /opt/kaltura/app/onlooker/onlooker /etc/init.d/


chkconfig onlooker on
service onlooker start
