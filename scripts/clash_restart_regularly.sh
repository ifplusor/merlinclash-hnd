#!/bin/sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt

eval `dbus export merlinclash_`


remove_clash_restart_regularly(){
	if [ -n "$(cru l|grep clash_restart)" ]; then
		
		sed -i '/clash_restart/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
}
start_clash_restart_regularly_day(){
	remove_clash_restart_regularly
	cru a clash_restart ${merlinclash_select_clash_restart_minute} ${merlinclash_select_clash_restart_hour}" * * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
}
start_clash_restart_regularly_week(){
	remove_clash_restart_regularly
	cru a clash_restart ${merlinclash_select_clash_restart_minute} ${merlinclash_select_clash_restart_hour}" * * "${merlinclash_select_clash_restart_week}" /bin/sh /koolshare/scripts/clash_restart_update.sh"
}
start_clash_restart_regularly_month(){
	remove_clash_restart_regularly
	cru a clash_restart ${merlinclash_select_clash_restart_minute} ${merlinclash_select_clash_restart_hour} ${merlinclash_select_clash_restart_day}" * * /bin/sh /koolshare/scripts/clash_restart_update.sh"

}
start_clash_restart_regularly_mhour(){
	remove_clash_restart_regularly
	if [ "$merlinclash_select_clash_restart_minute_2" == "2" ] || [ "$merlinclash_select_clash_restart_minute_2" == "5" ] || [ "$merlinclash_select_clash_restart_minute_2" == "10" ] || [ "$merlinclash_select_clash_restart_minute_2" == "15" ] || [ "$merlinclash_select_clash_restart_minute_2" == "20" ] || [ "$merlinclash_select_clash_restart_minute_2" == "25" ] || [ "$merlinclash_select_clash_restart_minute_2" == "30" ]; then
		cru a clash_restart "*/"${merlinclash_select_clash_restart_minute_2}" * * * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
	fi
	if [ "$merlinclash_select_clash_restart_minute_2" == "1" ] || [ "$merlinclash_select_clash_restart_minute_2" == "3" ] || [ "$merlinclash_select_clash_restart_minute_2" == "6" ] || [ "$merlinclash_select_clash_restart_minute_2" == "12" ]; then
		cru a clash_restart "0 */"${merlinclash_select_clash_restart_minute_2} "* * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
	fi
}

case $merlinclash_select_clash_restart in
1)
	remove_clash_restart_regularly
	http_response "close"
	;;
2)
	start_clash_restart_regularly_day
	http_response "open"
	;;
3)
	start_clash_restart_regularly_week
	http_response "open"
	;;
4)
	start_clash_restart_regularly_month
	http_response "open"
	;;
5)
	start_clash_restart_regularly_mhour
	http_response "open"
	;;
*)
	remove_clash_restart_regularly
	http_response "close"
	;;
esac
