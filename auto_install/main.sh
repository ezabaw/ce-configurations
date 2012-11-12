#!/bin/sh -e

. `dirname $0`/kaltura.rc
cat << EOF 
Welcome to Kaltura $KALT_VER setup tool
Please select one of the following options:
1. batch instance
2. sphinx instance
3. API machine
4. export Kaltura's MySQL DBs
5. unistall
6. configure MySQL && Sphinx for this host
EOF
read CHOICE
#if [ $CHOICE = 0 ];then
	#echo "About to create an all in one instance.."
#fi
# if we are not all in one, make sure the user didn't set DB creation to 'y' by mistake.
if [ $CHOICE = 1 ];then
	echo "About to create a batch instance.."
	probe_for_garbage
	install_all_in_one
	install_batch
elif [ $CHOICE = 2 ];then
	echo "About to create a Sphinx instance.."	
	probe_for_garbage
	install_all_in_one
	install_sphinx
elif [ $CHOICE = 3 ];then
	echo "About to create an API instance.."
	probe_for_garbage
	install_all_in_one
	install_api
elif [ $CHOICE = 4 ];then
	echo "About to export Kaltura's MySQL DB.."
	export_mysql_kalt_db
elif [ $CHOICE = 5 ];then
	echo "Uninstall"
	`dirname $0`/cleanup.sh
elif [ $CHOICE = 6 ];then
	echo "About to configure MySQL && Sphinx for this host.."
	set_mysqldb_host
else
	echo "Choose a value between 1-6"
	exit 1
fi

