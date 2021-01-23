#!/bin/sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
LOCK_FILE=/var/lock/merlinclash.lock
eval `dbus export merlinclash_`


remove_regular_subscribe(){
	if [ -n "$(cru l|grep regular_subscribe)" ]; then
		
		sed -i '/regular_subscribe/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
}
start_regular_subscribe_day(){
	remove_regular_subscribe
	cru a regular_subscribe ${merlinclash_select_regular_minute} ${merlinclash_select_regular_hour}" * * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
}
start_regular_subscribe_week(){
	remove_regular_subscribe
	cru a regular_subscribe ${merlinclash_select_regular_minute} ${merlinclash_select_regular_hour}" * * "${merlinclash_select_regular_week}" /bin/sh /koolshare/scripts/clash_regular_update.sh"
}
start_regular_subscribe_month(){
	remove_regular_subscribe
	cru a regular_subscribe ${merlinclash_select_regular_minute} ${merlinclash_select_regular_hour} ${merlinclash_select_regular_day}" * * /bin/sh /koolshare/scripts/clash_regular_update.sh"

}
start_regular_subscribe_mhour(){
	remove_regular_subscribe
	if [ "$merlinclash_select_regular_minute_2" == "2" ] || [ "$merlinclash_select_regular_minute_2" == "5" ] || [ "$merlinclash_select_regular_minute_2" == "10" ] || [ "$merlinclash_select_regular_minute_2" == "15" ] || [ "$merlinclash_select_regular_minute_2" == "20" ] || [ "$merlinclash_select_regular_minute_2" == "25" ] || [ "$merlinclash_select_regular_minute_2" == "30" ]; then
		cru a regular_subscribe "*/"${merlinclash_select_regular_minute_2}" * * * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
	fi
	if [ "$merlinclash_select_regular_minute_2" == "1" ] || [ "$merlinclash_select_regular_minute_2" == "3" ] || [ "$merlinclash_select_regular_minute_2" == "6" ] || [ "$merlinclash_select_regular_minute_2" == "12" ]; then
		cru a regular_subscribe "0 */"${merlinclash_select_regular_minute_2} "* * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
	fi
}

case $merlinclash_select_regular_subscribe in
1)
	remove_regular_subscribe
	http_response "close"
	;;
2)
	start_regular_subscribe_day
	http_response "open"
	;;
3)
	start_regular_subscribe_week
	http_response "open"
	;;
4)
	start_regular_subscribe_month
	http_response "open"
	;;
5)
	start_regular_subscribe_mhour
	http_response "open"
	;;
*)
	remove_regular_subscribe
	http_response "close"
	;;
esac
