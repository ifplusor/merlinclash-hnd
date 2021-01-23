#!/bin/sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
LOCK_FILE=/var/lock/merlinclash.lock
eval `dbus export merlinclash_`


remove_unblock_restart_job(){
	if [ -n "$(cru l|grep unblock_restart)" ]; then
		#echo_date "【网易云音乐解锁】：删除网易云音乐解锁自动重启定时任务..."
		sed -i '/unblock_restart/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
}
start_unblock_restart_job_day(){
	remove_unblock_restart_job
	cru a unblock_restart ${merlinclash_select_minute} ${merlinclash_select_hour}" * * * /bin/sh /koolshare/scripts/clash_unblockneteasemusic.sh restart"
}
start_unblock_restart_job_week(){
	remove_unblock_restart_job
	cru a unblock_restart ${merlinclash_select_minute} ${merlinclash_select_hour}" * * "${merlinclash_select_week}" /bin/sh /koolshare/scripts/clash_unblockneteasemusic.sh restart"
}
start_unblock_restart_job_month(){
	remove_unblock_restart_job
	cru a unblock_restart ${merlinclash_select_minute} ${merlinclash_select_hour} ${merlinclash_select_day}" * * /bin/sh /koolshare/scripts/clash_unblockneteasemusic.sh restart"

}
case $merlinclash_select_job in
1)
	remove_unblock_restart_job
	http_response "close"
	;;
2)
	start_unblock_restart_job_day
	http_response "open"
	;;
3)
	start_unblock_restart_job_week
	http_response "open"
	;;
4)
	start_unblock_restart_job_month
	http_response "open"
	;;
*)
	remove_unblock_restart_job
	http_response "close"
	;;
esac
