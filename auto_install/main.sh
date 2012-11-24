#!/bin/sh -e

. `dirname $0`/kaltura.rc
cat << EOF 
Welcome to Kaltura $KALT_VER setup tool
Please select one of the following options:
0. install an all in 1 instance
1. batch instance
2. sphinx instance
3. front [API] machine
4. export Kaltura's MySQL DBs
5. configure MySQL && Sphinx for this host
6. check for port connectivity
7. unistall
EOF
read CHOICE
if [ $CHOICE = 0 ];then
	echo "About to create an all in one instance.."
	install_all_in_one
fi
# if we are not all in one, make sure the user didn't set DB creation to 'y' by mistake.
if [ $CHOICE = 1 ];then
	echo "About to create a batch instance.."
	probe_for_garbage
	install_all_in_one
	install_batch
	set_mysqldb_host
elif [ $CHOICE = 2 ];then
	echo "About to create a Sphinx instance.."	
	probe_for_garbage
	install_all_in_one
	install_sphinx
	set_mysqldb_host
elif [ $CHOICE = 3 ];then
	echo "About to create an API instance.."
	probe_for_garbage
	install_all_in_one
	install_api
	set_mysqldb_host
elif [ $CHOICE = 4 ];then
	echo "About to export Kaltura's MySQL DB.."
	export_mysql_kalt_db
elif [ $CHOICE = 5 ];then
	echo "About to configure MySQL && Sphinx for this host.."
	set_mysqldb_host
elif [ $CHOICE = 6 ];then
	echo "Checking network port connectivity.."
	check_port_connectivity
elif [ $CHOICE = 7 ];then
	echo "Uninstalling"
	`dirname $0`/cleanup.sh
else
	echo "Choose a value between 1-7"
	exit 1
fi
cd `dirname $0`
if [ $CHOICE -lt 4 ];then
	cp auto_inst_falcon_centos.sh cleanup.sh export_db.sh main.sh monit mysql_rep.sh create_* upload_csv.php monit.rc user_input.ini $DIR_NAME/etc/auto_inst
fi
