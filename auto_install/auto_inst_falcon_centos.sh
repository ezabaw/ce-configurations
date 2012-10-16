#!/bin/sh -e
. `dirname $0`/kaltura.rc
if [ $# -eq 1 ];then
    INSTALL_DIR=$1
else
    INSTALL_DIR=`pwd`
fi
install_deps
setup_pentaho
echo "Starting needed daemons.."
for i in httpd memcached;do
    /etc/init.d/$i start
    chkconfig $i on
done
set_selinux_permissive
echo "Setting request_order = CGP in php.ini"
sed -i 's@request_order\s*=\s*.*@request_order = "CGP"@' /etc/php.ini
cd $INSTALL_DIR && php install.php -s user_input.ini
sed -i 's@ = @=@g' $INSTALL_DIR/user_input.ini
. $INSTALL_DIR/user_input.ini
# Add the "kaltura" user
create_kalt_user
fix_permissions
sed -i 's@ root @ kaltura @' $BASE_DIR/crontab/kaltura_crontab
sed -i 's@kaltura /usr/sbin/logrotate@root /usr/sbin/logrotate@' $BASE_DIR/crontab/kaltura_crontab
configure_apache
sed -i 's@^kaltura_activation_key\s*=\s*@kaltura_activation_key = YjI2MzgwMmUyMDA0ZTA1ODg1MWFjYWJiNDExMTEzNWV8MXxuZXZlcnww@' $BASE_DIR/app/configurations/local.ini
configure_dwh
echo "Creating test partner.."
php $INSTALL_DIR/create_partner.php `echo "select admin_secret from partner where id=-2;" |mysql -u"$DB1_USER" -p"$DB1_PASS" -P$DB1_PORT $DB1_NAME |sed '1,1d'`
