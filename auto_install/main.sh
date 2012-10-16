#!/bin/bash -e

. `dirname $0`/kaltura.rc
cat << EOF 
Welcome to Kaltura $KALT_VER setup tool
Please select one of the following options:
0. all in one install
1. batch instance
2. sphinx instance
3. API machine
4. export Kaltura's MySQL DBs
EOF
read CHOICE
if [ $CHOICE = 0 ];then
	echo "About to create an all in one instance.."
	install_all_in_one
elif [ $CHOICE = 1 ];then
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
	
else
	echo "Choose a value between 0-4"
	exit 1
fi

