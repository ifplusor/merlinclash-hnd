#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt

ROUTE_IP=$(nvram get lan_ipaddr)
ipt_n="iptables -t nat"
serverCrt="/koolshare/bin/Music/server.crt"
serverKey="/koolshare/bin/Music/server.key"
ipset_music=$(ipset list music)
add_rule()
{
	echo_date 加载网易云音乐解锁nat规则... >> $LOG_FILE
	if [ -n "$ipset_music" ]; then
		echo_date "已存在ipset规则" >> $LOG_FILE
	else
		ipset -! -N music hash:ip
		ipset add music 59.111.181.60 
		ipset add music 59.111.181.38 
		ipset add music 59.111.181.35 
		ipset add music 59.111.160.195
		ipset add music 223.252.199.66
		ipset add music 59.111.160.197
		ipset add music 223.252.199.67
		ipset add music 115.236.121.1
		ipset add music 115.236.121.3
		ipset add music 115.236.118.33
		ipset add music 39.105.63.80
		ipset add music 118.24.63.156
		ipset add music 193.112.159.225
		ipset add music 47.100.127.239
		#20200712++++
		ipset add music 112.13.122.1
		ipset add music 112.13.119.17
		ipset add music 103.126.92.133
		ipset add music 103.126.92.132
		ipset add music 101.71.154.241
		ipset add music 59.111.238.29/
		ipset add music 59.111.179.214
		ipset add music 59.111.21.14
		ipset add music 45.254.48.1
		ipset add music 42.186.120.199
	fi
	#20200712----
	$ipt_n -N cloud_music
	$ipt_n -A cloud_music -d 0.0.0.0/8 -j RETURN
	$ipt_n -A cloud_music -d 10.0.0.0/8 -j RETURN
	$ipt_n -A cloud_music -d 127.0.0.0/8 -j RETURN
	$ipt_n -A cloud_music -d 169.254.0.0/16 -j RETURN
	$ipt_n -A cloud_music -d 172.16.0.0/12 -j RETURN
	$ipt_n -A cloud_music -d 192.168.0.0/16 -j RETURN
	$ipt_n -A cloud_music -d 224.0.0.0/4 -j RETURN
	$ipt_n -A cloud_music -d 240.0.0.0/4 -j RETURN
	$ipt_n -A cloud_music -p tcp --dport 80 -j REDIRECT --to-ports 5200
	$ipt_n -A cloud_music -p tcp --dport 443 -j REDIRECT --to-ports 5300
	$ipt_n -I PREROUTING -p tcp -m set --match-set music dst -j cloud_music
	iptables -I OUTPUT -d 223.252.199.10 -j DROP
}

del_rule(){
	echo_date 移除网易云音乐解锁nat规则... >> $LOG_FILE
	$ipt_n -D PREROUTING -p tcp -m set --match-set music dst -j cloud_music >/dev/null 2>&1 
	iptables -D OUTPUT -d 223.252.199.10 -j DROP >/dev/null 2>&1 
	$ipt_n -F cloud_music  >/dev/null 2>&1 
	$ipt_n -X cloud_music  >/dev/null 2>&1 	
	rm -f /tmp/etc/dnsmasq.user/dnsmasq-music.conf
}

set_firewall(){

	rm -f /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	#echo "ipset=/music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf #20200524
	echo "ipset=/.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/interface.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/interface3.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/apm.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/apm3.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/clientlog.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/clientlog3.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	service restart_dnsmasq >/dev/null 2>&1
	
	add_rule
}

remove_unblock_restart_job(){
	if [ -n "$(cru l|grep unblock_restart)" ]; then
		echo_date "删除网易云音乐解锁自动重启定时任务..." >> $LOG_FILE
		sed -i '/unblock_restart/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
}

start_unblock_restart_job_day(){
	remove_unblock_restart_job
	echo_date "创建网易云音乐解锁自动重启定时任务..." >> $LOG_FILE
	cru a unblock_restart ${merlinclash_select_minute} ${merlinclash_select_hour}" * * * /bin/sh /koolshare/scripts/clash_unblockneteasemusic.sh restart"
}
start_unblock_restart_job_week(){
	remove_unblock_restart_job
	echo_date "创建网易云音乐解锁自动重启定时任务..." >> $LOG_FILE
	cru a unblock_restart ${merlinclash_select_minute} ${merlinclash_select_hour}" * * "${merlinclash_select_week}" /bin/sh /koolshare/scripts/clash_unblockneteasemusic.sh restart"
}
start_unblock_restart_job_month(){
	remove_unblock_restart_job
	echo_date "创建网易云音乐解锁自动重启定时任务..." >> $LOG_FILE
	cru a unblock_restart ${merlinclash_select_minute} ${merlinclash_select_hour} ${merlinclash_select_day}" * * /bin/sh /koolshare/scripts/clash_unblockneteasemusic.sh restart"

}

start_unblock_restart_job(){
	case $merlinclash_select_job in
	1)
		remove_unblock_restart_job
		;;
	2)
		start_unblock_restart_job_day
		;;
	3)
		start_unblock_restart_job_week
		;;
	4)
		start_unblock_restart_job_month
		;;
	esac
}

start_unblockmusic(){
	echo_date "开启网易云音乐解锁功能" >> $LOG_FILE
	
	stop_unblockmusic
	remove_unblock_restart_job

	if [ $merlinclash_unblockmusic_enable -eq 0 ]; then
		echo_date "解锁开关未开启，退出" >> $LOG_FILE
		exit 0
	fi
	endponintset="";
	if [ -n "$merlinclash_unblockmusic_endpoint" ]; then
		endponintset="-e"
	fi
	ver="0.2.5"
	echo_date "当前二进制版本为$merlinclash_UnblockNeteaseMusic_version" >> $LOG_FILE
	COMP=$(versioncmp $merlinclash_UnblockNeteaseMusic_version $ver)
	if [ "$COMP" == "-1" ] || [ "$COMP" == "0" ]  ; then
		echo_date "当前版本可开启显示搜索结果数：$merlinclash_unblockmusic_platforms_numbers" >> $LOG_FILE
		if [ "$merlinclash_unblockmusic_musicapptype" == "default" ]; then
			if [ "$merlinclash_unblockmusic_bestquality" == "1" ]; then
				/koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -m 0 -sl "${merlinclash_unblockmusic_platforms_numbers}" -c "${serverCrt}" -k "${serverKey}" "${endponintset}" -b >/dev/null 2>&1 &
			else
				/koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -m 0 -sl "${merlinclash_unblockmusic_platforms_numbers}" -c "${serverCrt}" -k "${serverKey}" "${endponintset}" >/dev/null 2>&1 &
			fi
		
		else
			if [ "$merlinclash_unblockmusic_bestquality" == "1" ]; then
				/koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -o "$merlinclash_unblockmusic_musicapptype" -m 0 -sl "${merlinclash_unblockmusic_platforms_numbers}" -c "${serverCrt}" -k "${serverKey}" "${endponintset}" -b >/dev/null 2>&1 &
			else
				/koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -o "$merlinclash_unblockmusic_musicapptype" -m 0 -sl "${merlinclash_unblockmusic_platforms_numbers}" -c "${serverCrt}" -k "${serverKey}" "${endponintset}" >/dev/null 2>&1 &
			fi
		fi
	else
		echo_date "当前版本不可开启显示搜索结果数" >> $LOG_FILE
		if [ "$merlinclash_unblockmusic_musicapptype" == "default" ]; then
			if [ "$merlinclash_unblockmusic_bestquality" == "1" ]; then
				/koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -m 0 -c "${serverCrt}" -k "${serverKey}" "${endponintset}" -b >/dev/null 2>&1 &
			else
				/koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -m 0 -c "${serverCrt}" -k "${serverKey}" "${endponintset}" >/dev/null 2>&1 &
			fi
		
		else
			if [ "$merlinclash_unblockmusic_bestquality" == "1" ]; then
				/koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -o "$merlinclash_unblockmusic_musicapptype" -m 0 -c "${serverCrt}" -k "${serverKey}" "${endponintset}" -b >/dev/null 2>&1 &
			else
				/koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -o "$merlinclash_unblockmusic_musicapptype" -m 0 -c "${serverCrt}" -k "${serverKey}" "${endponintset}" >/dev/null 2>&1 &
			fi
		
		fi
		
	fi
	
	echo_date "设置相关iptable规则" >> $LOG_FILE
	set_firewall
	ubm_process=$(pidof UnblockNeteaseMusic);
	if [ -n "$ubm_process" ]; then
		echo_date "网易云音乐解锁启动完成，pid：$ubm_process" >> $LOG_FILE
		start_unblock_restart_job
	fi
}

stop_unblockmusic(){
	kill -9 $(busybox ps -w | grep UnblockNeteaseMusic | grep -v grep | awk '{print $1}') >/dev/null 2>&1 &
	del_rule
	remove_unblock_restart_job
}

case $1 in
start)
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		echo_date "开启网易云音乐解锁" >> $LOG_FILE
		start_unblockmusic
	fi
	;;
restart)
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		echo_date "开启网易云音乐解锁" >> $LOG_FILE
		start_unblockmusic
	fi
	;;
stop)
	echo_date "关闭网易云音乐解锁" >> $LOG_FILE
	stop_unblockmusic
	;;
*)
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		start_unblockmusic
	else
		stop_unblockmusic
	fi
	;;
esac

