#!/bin/sh -e

. `dirname $0`/kaltura.rc
probe_for_garbage
cat << EOF 
Welcome to Kaltura $KALT_VER setup tool
Please select one of the following options:
1. batch instance
2. sphinx instance
3. API machine
4. export Kaltura's MySQL DBs
5. unistall
6. configure Sphinx for this host
7. configure DB for this host
EOF
read CHOICE
#if [ $CHOICE = 0 ];then
	#echo "About to create an all in one instance.."
	install_all_in_one
#fi
# if we are not all in one, make sure the user didn't set DB creation to 'y' by mistake.
prompt_for_mysql_dsn
if [ $CHOICE = 1 ];then
	echo "About to create a batch instance.."
	install_batch
elif [ $CHOICE = 2 ];then
	echo "About to create a Sphinx instance.."
	install_sphinx
elif [ $CHOICE = 3 ];then
	echo "About to create an API instance.."
	install_api
elif [ $CHOICE = 4 ];then
	echo "About to export Kaltura's MySQL DB.."
	export_mysql_kalt_db
elif [ $CHOICE = 5 ];then
	echo "Uninstall"
	`dirname $0`/cleanup.sh
elif [ $CHOICE = 6 ];then
	echo "About to configure Sphinx for this host.."
	set_sphinx
elif [ $CHOICE = 7 ];then
	echo "About to configure MySQL DB for this host.."
	set_mysqldb
else
	echo "Choose a value between 1-7"
	exit 1
fi

