Script: Kaltura Gemini Auto Installer for On-Prem Installations

todo
fix the replacement of the package directory in config or see if you can pass a variable to the installer
check mysql connectivity if mysql create database is set to no
check if items exist already and offer uninstall, of course create uninstall
add in variable checks for configuration file 


Known bugs:
-No rollback on installation
-Failed to create symbolic link [/etc/nagios/conf.d/kaltura.commands.cfg], target [/opt/kaltura/app/plugins/monitor/nagios/config/commands.cfg] does not exist.


Coming soon:

mysql master/slave installation
rollback for all components
task selection for kaltura
