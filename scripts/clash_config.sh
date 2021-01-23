#!/bin/sh

source /koolshare/scripts/base.sh
eval `dbus export merlinclash_`
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
mkdir -p /tmp/upload
rm -rf /tmp/upload/merlinclash_log.txt
echo "" > /tmp/upload/merlinclash_log.txt
http_response "$1"

case $2 in
start)
	if [ "$merlinclash_enable" == "1" ];then
		echo start >> /tmp/upload/merlinclash_log.txt
		sh /koolshare/merlinclash/clashconfig.sh restart >> /tmp/upload/merlinclash_log.txt
	else
		echo stop >> /tmp/upload/merlinclash_log.txt
		sh /koolshare/merlinclash/clashconfig.sh stop >> /tmp/upload/merlinclash_log.txt
	fi

	echo BBABBBBC >> /tmp/upload/merlinclash_log.txt
	;;
upload)
	echo upload >> /tmp/upload/merlinclash_log.txt
	sh /koolshare/merlinclash/clashconfig.sh upload
	echo BBABBBBC >> /tmp/upload/merlinclash_log.txt
	;;
update)
	echo update >> /tmp/upload/merlinclash_log.txt
	sh /koolshare/merlinclash/clash_update_ipdb.sh
	echo BBABBBBC >> /tmp/upload/merlinclash_log.txt
	;;
quicklyrestart)
	if [ "$merlinclash_enable" == "1" ];then
		echo "快速重启" >> /tmp/upload/merlinclash_log.txt
		sh /koolshare/merlinclash/clashconfig.sh quicklyrestart >> /tmp/upload/merlinclash_log.txt
	else
		echo "请先启用merlinclash" >> /tmp/upload/merlinclash_log.txt		
	fi
	echo BBABBBBC >> /tmp/upload/merlinclash_log.txt
	;;
unblockmusicrestart)
	if [ "$merlinclash_enable" == "1" ];then
		echo "网易云音乐解锁快速重启" >> /tmp/upload/merlinclash_log.txt
		sh /koolshare/scripts/clash_unblockneteasemusic.sh restart
	else
		echo "请先启用merlinclash" >> /tmp/upload/merlinclash_log.txt		
	fi
	echo BBABBBBC >> /tmp/upload/merlinclash_log.txt
	;;
esac