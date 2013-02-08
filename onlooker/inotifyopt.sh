#!/bin/bash

DEBUG=0

ENDTIME=`date +%s%N | cut -b1-13`

git add /opt/
git commit -am 'inotify commit - opt'

inotifywait -mr \
--timefmt '%d/%m/%y %H:%M' \
--format '%T %w %f %e' \
--exclude "(\/opt\/nfs\/web\/tmp)|(\/opt\/kaltura\/app\/batch\/controls\/)|(\/opt\/kaltura\/app\/cache\/)|(\/opt\/adobe\/ams\/tmp)|(searchd_is_not_running_email$)|(\.log$)|(\.rpm$)|(\.mpg$)|(\.srt$)|(\.ainfo$)|(\.vmetadata$)|(\.ametadata$)|(\.vinfo$)|(\.ogg$)|(\.3gp$)|(\.webm$)|(\.rm$)|(\.swf$)|(\.avi$)|(\.f4v$)|(\.ja$)|(\.mp4$)|(\.jpg$)|(\.png$)|(\.jar$)|(\.mp3$)|(\.wav$)|(\.wmv$)|(\.mov$)|(\.flv$)|(\.zip$)|(\.gz$)|(\.tar$)|(\.tar.gz$)|(\.ttf$)|(\.pdf$)|(\.img$)|(\.x86_64$)" \
-e modify \
-e attrib \
-e moved_to \
-e moved_from \
-e create \
-e delete /opt/ | while read date time dir file type; do

	if [ "${DEBUG}" -eq "1" ];then
		echo "read ${read} date ${date} time ${time} file ${file} dir ${dir} type ${type}" >> /opt/kaltura/app/onlooker/inotifyopt.log
	fi

	#If this was last run less .8 seconds ago then skip the git commit so we arent too intensive.
	TIME=`date +%s%N | cut -b1-13`
	TIMEDIFF=`expr ${TIME} - ${ENDTIME}`
	#echo "TIMEDIFF IS $TIMEDIFF"
	if [ "${TIMEDIFF}" -gt "500" ]; then 

		if [ "${type}" = "MODIFY" -o "${type}" = "ATTRIB" -o "${type}" = "DELETE" -o "${type}" = "DELETE,ISDIR" ];then
			git commit -am 'inotify commit - opt'
		fi
		if [ "${type}" = "CREATE" -o "${type}" = "CREATE,ISDIR" ];then
			git add ${dir}${file}
			git commit -am 'inotify commit - opt'
		fi
	elif [ "${type}" = "CREATE" -o "${type}" = "CREATE,ISDIR" ];then
		git add ${dir}${file}
	fi
	
	ENDTIME=`date +%s%N | cut -b1-13`

done
