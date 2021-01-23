#!/bin/sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
LOCK_FILE=/var/lock/merlinclash.lock
eval `dbus export merlinclash_`

yamlname=$merlinclash_yamlsel
#配置文件路径
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml
#提取配置认证码
secret=$(cat $yamlpath | awk '/secret:/{print $2}' | sed 's/"//g')
#提取配置监听端口
ecport=$(cat $yamlpath | awk -F: '/external-controller/{print $3}')
#20200904 新增host.yaml处理
hostsyaml=/koolshare/merlinclash/yaml_basic/hosts.yaml

chromecast_nu=""
lan_ipaddr=$(nvram get lan_ipaddr)
ssh_port=$(nvram get sshd_port)
head_tmp=/koolshare/merlinclash/yaml_basic/head.yaml
rm -rf /tmp/upload/clash_error.log
rm -rf /tmp/upload/dns_read_error.log
ip_prefix_hex=$(nvram get lan_ipaddr | awk -F "." '{printf ("0x%02x", $1)} {printf ("%02x", $2)} {printf ("%02x", $3)} {printf ("00/0xffffff00\n")}')
uploadpath=/tmp/upload
bridge=$(ifconfig | grep br | awk -F' ' '{print $1}')

set_lock() {
	exec 1000>"$LOCK_FILE"
	flock -x 1000
}

unset_lock() {
	flock -u 1000
	rm -rf "$LOCK_FILE"
}
decode_url_link(){
	local link=$1
	local len=$(echo $link | wc -L)
	local mod4=$(($len%4))
	if [ "$mod4" -gt "0" ]; then
		local var="===="
		local newlink=${link}${var:$mod4}
		echo -n "$newlink" | sed 's/-/+/g; s/_/\//g' | base64 -d 2>/dev/null
	else
		echo -n "$link" | sed 's/-/+/g; s/_/\//g' | base64 -d 2>/dev/null
	fi
}
urldecode(){
  printf $(echo -n "$1" | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g')"\n"
}

move_config(){
	#查找upload文件夹是否有刚刚上传的yaml文件，正常只有一份
	#name=$(find $uploadpath  -name "$yamlname.yaml" |sed 's#.*/##')
	echo_date "上传的文件名是$merlinclash_uploadfilename" >> $LOG_FILE
	if [ -f "/tmp/upload/$merlinclash_uploadfilename" ]; then
		#后台执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/koolshare/merlinclash/并命名为上传文件名.yaml
		#echo_date "后台执行yaml文件处理工作"
		#sh /koolshare/scripts/clash_yaml_sub.sh >/dev/null 2>&1 &
		echo_date "yaml文件合法性检查" >> $LOG_FILE
		check_yamlfile
		if [ $flag == "1" ]; then
			echo_date "执行yaml文件处理工作"
			mkdir -p /tmp/upload/yaml
			rm -rf /tmp/upload/yaml/*
			cp -rf /tmp/upload/$merlinclash_uploadfilename /tmp/upload/yaml/$merlinclash_uploadfilename
			sh /koolshare/scripts/clash_yaml_upload_sub.sh
		fi
	else
		echo_date "没找到yaml文件"
		rm -rf /tmp/upload/*.yaml
		exit 1
	fi


}
check_yamlfile(){
	#通过获取的文件是否存在port: Rule: Proxy: Proxy Group: 标题头确认合法性
	#先处理下文本
	flag=0
	sh /koolshare/scripts/clash_string.sh /tmp/upload/$merlinclash_uploadfilename
	para1=$(sed -n '/^port:/p' /tmp/upload/$merlinclash_uploadfilename)
	para1_1=$(sed -n '/^mixed-port:/p' /tmp/upload/$merlinclash_uploadfilename)
	#para2=$(sed -n '/^socks-port:/p' /tmp/upload/$upname)
	#para3=$(sed -n '/^mode:/p' /tmp/upload/$upname)
	#para4=$(sed -n '/^name:/p' /tmp/upload/upload.yaml)
	#para5=$(sed -n '/^type:/p' /tmp/upload/upload.yaml)
	proxies_line=$(cat /tmp/upload/$merlinclash_uploadfilename | grep -n "^proxies:" | awk -F ":" '{print $1}')
	#20200902+++++++++++++++
	#COMP 左>右，值-1；左等于右，值0；左<右，值1
	port_line=$(cat /tmp/upload/$merlinclash_uploadfilename | grep -n "^port:" | awk -F ":" '{print $1}')
	echo_date "port:行数为$port_line" >> $LOG_FILE
	echo_date "proxies:行数为$proxies_line" >> $LOG_FILE
	if [ -z "$port_line" ] ; then
		echo_date "配置文件缺少port:开头行，无法创建yaml文件" >> $LOG_FILE
		#rm -rf /tmp/upload/$upname
		echo BBABBBBC >> $LOG_FILE
		exit 1

	fi
	if [ -z "$proxies_line" ]; then
		echo_date "配置文件缺少proxies:开头行，无法创建yaml文件" >> $LOG_FILE
		#rm -rf /tmp/upload/$upname
		echo BBABBBBC >> $LOG_FILE
		exit 1

	fi
	if [ -z "$para1" ] && [ -z "$para1_1" ]; then
		echo_date "clash配置文件不是合法的yaml文件，请检查订阅连接是否有误" >> $LOG_FILE
		rm -rf /tmp/upload/$merlinclash_uploadfilename
		echo BBABBBBC >> $LOG_FILE
		exit 1
	else
		echo_date "clash配置文件检查通过" >> $LOG_FILE
		flag=1
	fi
}
watchdog(){
	if [ "$merlinclash_enable" == "1" ] && [ "$merlinclash_watchdog" == "1" ];then
		sed -i '/clash_watchdog/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
		watcdogtime=$merlinclash_watchdog_delay_time
		cru a clash_watchdog "*/$watcdogtime * * * * /bin/sh /koolshare/scripts/clash_watchdog.sh"
	#	/bin/sh /koolshare/scripts/clash_watchdog.sh >/dev/null 2>&1 &
	else
		#pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
		#if [ -n "$pid_watchdog" ]; then
		echo_date 关闭看门狗... >> $LOG_FILE
		# 有时候killall杀不了v2ray进程，所以用不同方式杀两次
		#kill -9 "$pid_watchdog" >/dev/null 2>&1
		sed -i '/clash_watchdog/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
		#fi
	fi
}

write_setmark_cron_job(){
	sed -i '/autosermark/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	sed -i '/autologdel/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	if [ "$merlinclash_enable" == "1" ];then
		if [ ! -z "$(pidof clash)" -a ! -z "$(netstat -anp | grep clash)" -a ! -n "$(grep "Parse config error" /tmp/clash_run.log)" ] ; then
			echo_date "添加自动获取节点信息任务，每分钟自动检测节点选择状态." >> $LOG_FILE
			cru a autosermark "* * * * * /bin/sh /koolshare/scripts/clash_node_mark.sh setmark"
			#同时启动日志监测，1小时检测一次
			cru a autologdel "0 * * * * /bin/sh /koolshare/scripts/clash_logautodel.sh"
		#	/bin/sh /koolshare/scripts/clash_node_mark.sh setmark >/dev/null 2>&1 &			
		else	
			echo_date "clash进程故障，不开启自动获取节点信息" >> $LOG_FILE
		fi
	fi
}
write_clash_restart_cron_job(){
	remove_clash_restart_regularly(){
		if [ -n "$(cru l|grep clash_restart)" ]; then		
			sed -i '/clash_restart/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
		fi
	}
	start_clash_restart_regularly_day(){
		remove_clash_restart_regularly
		cru a clash_restart ${merlinclash_select_clash_restart_minute} ${merlinclash_select_clash_restart_hour}" * * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
		echo_date "clash将于每日的${merlinclash_select_clash_restart_hour}时${merlinclash_select_clash_restart_minute}分重启" >> $LOG_FILE
	}
	start_clash_restart_regularly_week(){
		remove_clash_restart_regularly
		cru a clash_restart ${merlinclash_select_clash_restart_minute} ${merlinclash_select_clash_restart_hour}" * * "${merlinclash_select_clash_restart_week}" /bin/sh /koolshare/scripts/clash_restart_update.sh"
		echo_date "clash将于每周${merlinclash_select_clash_restart_week}的${merlinclash_select_clash_restart_hour}时${merlinclash_select_clash_restart_minute}分重启" >> $LOG_FILE
	}
	start_clash_restart_regularly_month(){
		remove_clash_restart_regularly
		cru a clash_restart ${merlinclash_select_clash_restart_minute} ${merlinclash_select_clash_restart_hour} ${merlinclash_select_clash_restart_day}" * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
		echo_date "clash将于每月${merlinclash_select_clash_restart_day}号的${merlinclash_select_clash_restart_hour}时${merlinclash_select_clash_restart_minute}分重启" >> $LOG_FILE
	}

	start_clash_restart_regularly_mhour(){
		remove_clash_restart_regularly
		if [ "$merlinclash_select_clash_restart_minute_2" == "2" ] || [ "$merlinclash_select_clash_restart_minute_2" == "5" ] || [ "$merlinclash_select_clash_restart_minute_2" == "10" ] || [ "$merlinclash_select_clash_restart_minute_2" == "15" ] || [ "$merlinclash_select_clash_restart_minute_2" == "20" ] || [ "$merlinclash_select_clash_restart_minute_2" == "25" ] || [ "$merlinclash_select_clash_restart_minute_2" == "30" ]; then
			cru a clash_restart "*/"${merlinclash_select_clash_restart_minute_2}" * * * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
			echo_date "clash将每隔${merlinclash_select_clash_restart_minute_2}分钟重启" >> $LOG_FILE
		fi
		if [ "$merlinclash_select_clash_restart_minute_2" == "1" ] || [ "$merlinclash_select_clash_restart_minute_2" == "3" ] || [ "$merlinclash_select_clash_restart_minute_2" == "6" ] || [ "$merlinclash_select_clash_restart_minute_2" == "12" ]; then
			cru a clash_restart "0 */"${merlinclash_select_clash_restart_minute_2} "* * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
			echo_date "clash将每隔${merlinclash_select_clash_restart_minute_2}小时重启" >> $LOG_FILE
		fi
	}
	case $merlinclash_select_clash_restart in
	1)
		echo_date "定时重启处于关闭状态" >> $LOG_FILE
		remove_clash_restart_regularly
		;;
	2)
		start_clash_restart_regularly_day
		;;
	3)
		start_clash_restart_regularly_week
		;;
	4)
		start_clash_restart_regularly_month
		;;
	5)
		start_clash_restart_regularly_mhour
		;;
	*)
		echo_date "定时重启处于关闭状态" >> $LOG_FILE
		remove_clash_restart_regularly
		;;
	esac
}
write_regular_cron_job(){
	remove_regular_subscribe(){
		if [ -n "$(cru l|grep regular_subscribe)" ]; then		
			sed -i '/regular_subscribe/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
		fi
	}
	start_regular_subscribe_day(){
		remove_regular_subscribe
		cru a regular_subscribe ${merlinclash_select_regular_minute} ${merlinclash_select_regular_hour}" * * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
		echo_date "将于每日的${merlinclash_select_regular_hour}时${merlinclash_select_regular_minute}分重新订阅" >> $LOG_FILE
	}
	start_regular_subscribe_week(){
		remove_regular_subscribe
		cru a regular_subscribe ${merlinclash_select_regular_minute} ${merlinclash_select_regular_hour}" * * "${merlinclash_select_regular_week}" /bin/sh /koolshare/scripts/clash_regular_update.sh"
		echo_date "将于每周${merlinclash_select_regular_week}的${merlinclash_select_regular_hour}时${merlinclash_select_regular_minute}分重新订阅" >> $LOG_FILE
	}
	start_regular_subscribe_month(){
		remove_regular_subscribe
		cru a regular_subscribe ${merlinclash_select_regular_minute} ${merlinclash_select_regular_hour} ${merlinclash_select_regular_day}" * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
		echo_date "将于每月${merlinclash_select_regular_day}号的${merlinclash_select_regular_hour}时${merlinclash_select_regular_minute}分重新订阅" >> $LOG_FILE
	}

	start_regular_subscribe_mhour(){
		remove_regular_subscribe
		if [ "$merlinclash_select_regular_minute_2" == "2" ] || [ "$merlinclash_select_regular_minute_2" == "5" ] || [ "$merlinclash_select_regular_minute_2" == "10" ] || [ "$merlinclash_select_regular_minute_2" == "15" ] || [ "$merlinclash_select_regular_minute_2" == "20" ] || [ "$merlinclash_select_regular_minute_2" == "25" ] || [ "$merlinclash_select_regular_minute_2" == "30" ]; then
			cru a regular_subscribe "*/"${merlinclash_select_regular_minute_2}" * * * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
			echo_date "将每隔${merlinclash_select_regular_minute_2}分钟重新订阅" >> $LOG_FILE
		fi
		if [ "$merlinclash_select_regular_minute_2" == "1" ] || [ "$merlinclash_select_regular_minute_2" == "3" ] || [ "$merlinclash_select_regular_minute_2" == "6" ] || [ "$merlinclash_select_regular_minute_2" == "12" ]; then
			cru a regular_subscribe "0 */"${merlinclash_select_regular_minute_2} "* * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
			echo_date "将每隔${merlinclash_select_regular_minute_2}小时重新订阅" >> $LOG_FILE
		fi
	}
	case $merlinclash_select_regular_subscribe in
	1)
		echo_date "定时订阅处于关闭状态" >> $LOG_FILE
		remove_regular_subscribe
		;;
	2)
		start_regular_subscribe_day
		;;
	3)
		start_regular_subscribe_week
		;;
	4)
		start_regular_subscribe_month
		;;
	5)
		start_regular_subscribe_mhour
		;;
	*)
		echo_date "定时订阅处于关闭状态" >> $LOG_FILE
		remove_regular_subscribe
		;;
	esac
}
kill_cron_job() {
	if [ -n "$(cru l | grep autosermark)" ]; then
		echo_date 删除自动获取节点信息任务... >> $LOG_FILE
		sed -i '/autosermark/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
	if [ -n "$(cru l | grep autologdel)" ]; then
		echo_date 删除日志监测任务... >> $LOG_FILE
		sed -i '/autologdel/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
	if [ -n "$(cru l | grep clash_watchdog)" ]; then
		echo_date 删除看门狗任务... >> $LOG_FILE
		sed -i '/clash_watchdog/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
	if [ -n "$(cru l|grep regular_subscribe)" ]; then
		echo_date 删除定时订阅任务... >> $LOG_FILE	
		sed -i '/regular_subscribe/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
	if [ -n "$(cru l|grep clash_restart)" ]; then
		echo_date 删除定时重启任务... >> $LOG_FILE	
		sed -i '/clash_restart/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
}

kill_setmark(){
	pid_setmark=$(ps | grep clash_node_mark.sh | grep -v grep | awk '{print $1}')
	if [ -n "$pid_setmark" ]; then
		echo_date 关闭节点状态获取进程...
		# 有时候killall杀不了v2ray进程，所以用不同方式杀两次
		kill -9 "$pid_setmark" >/dev/null 2>&1
	fi
}

kill_process() {
	clash_process=$(pidof clash)
	#pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
	kcp_process=$(pidof client_linux_arm64)
	haveged_process=$(pidof haveged_c)
	#pid_setmark=$(ps | grep clash_node_mark.sh | grep -v grep | awk '{print $1}')
	if [ -n "$kcp_process" ]; then
		echo_date 关闭kcp协议进程... >> $LOG_FILE
		killall client_linux_arm64 >/dev/null 2>&1
	fi
	if [ -n "$clash_process" ]; then
		echo_date 关闭clash进程...
		# 有时候killall杀不了clash进程，所以用不同方式杀两次
		killall clash >/dev/null 2>&1
		kill -9 "$clash_process" >/dev/null 2>&1
	fi
	if [ -n "$haveged_process" ]; then
		echo_date "关闭haveged进程." >> $LOG_FILE
		killall haveged_c >/dev/null 2>&1
	fi
	#if [ -n "$pid_watchdog" ]; then
	#	echo_date 关闭看门狗进程...
		# 有时候killall杀不了watchdog进程，所以用不同方式杀两次
	#	kill -9 "$pid_watchdog" >/dev/null 2>&1
	#fi
	#if [ -n "$pid_setmark" ]; then
	#	echo_date 关闭节点状态获取进程...
	#	# 有时候killall杀不了v2ray进程，所以用不同方式杀两次
	#	kill -9 "$pid_setmark" >/dev/null 2>&1
	#fi
}
kill_clash() {
	clash_process=$(pidof clash)	
		if [ -n "$clash_process" ]; then
		echo_date 关闭clash进程...
		# 有时候killall杀不了clash进程，所以用不同方式杀两次
		killall clash >/dev/null 2>&1
		kill -9 "$clash_process" >/dev/null 2>&1
	fi	
}
flush_nat() {
	proxy_port=23457
	#ssh_port=22
	echo_date 清除iptables规则... >> $LOG_FILE
	# flush rules and set if any
	nat_indexs=$(iptables -nvL PREROUTING -t nat | sed 1,2d | sed -n '/clash/=' | sort -r)
	for nat_index in $nat_indexs; do
		iptables -t nat -D PREROUTING $nat_index >/dev/null 2>&1
	done
	mangle_indexs=$(iptables -nvL PREROUTING -t mangle | sed 1,2d | sed -n '/clash/=' | sort -r)
    for mangle_index in $mangle_indexs; do
        iptables -t mangle -D PREROUTING $mangle_index >/dev/null 2>&1
    done
	#清除外网访问端口
	iptables -D INPUT -p tcp --dport 9990 -j ACCEPT

	iptables -t nat -D PREROUTING -p tcp --dport $ssh_port -j ACCEPT >/dev/null 2>&1
	#DNS端口
	iptables -t nat -D PREROUTING -p udp -m udp --dport 53 -j DNAT --to-destination $lan_ipaddr:23453 >/dev/null 2>&1
	iptables -t nat -D PREROUTING -p tcp -j merlinclash
	iptables -t nat -D PREROUTING -p tcp -i br0 -j merlinclash
	#20200725清除设备绕行，测试++
	ipt_1=$(echo $lan_ipaddr | awk -F"." '{print $1}')
	ipt_2=$(echo $lan_ipaddr | awk -F"." '{print $2}')
	ipt_3=$(echo $lan_ipaddr | awk -F"." '{print $3}')
	ipt_4=$ipt_1.$ipt_2.$ipt_3
	#pass_indexs=$(iptables -nvL PREROUTING -t nat | sed 1,2d |  grep 'RETURN' | sed -n "/$ipt_3/=" | sort -r)
	#pass_indexs=$(iptables -nvL PREROUTING -t nat --line-number | sed 1,2d | grep 'RETURN' | sed -n "/$ipt_3/=" | awk '{print $1}'|sort -nr)
	pass_indexs=$(iptables -nvL PREROUTING -t nat --line-number | sed 1,2d | grep 'RETURN' | grep "$ipt_4" | awk '{print $1}'|sort -nr)
	for pass_index in $pass_indexs; do
		iptables -t nat -D PREROUTING $pass_index >/dev/null 2>&1
	done
	pass_indexs2=$(iptables -nvL PREROUTING -t mangle --line-number | sed 1,2d | grep 'RETURN' | grep "$ipt_4" | awk '{print $1}'|sort -nr)
	for pass_index2 in $pass_indexs2; do
		iptables -t mangle -D PREROUTING $pass_index >/dev/null 2>&1
	done
	#---------------------------
	iptables -t nat -D clash_dns -p udp -j REDIRECT --to-ports 23453
	iptables -t nat -D PREROUTING -p udp --dport 53 -j clash_dns
	iptables -t nat -D OUTPUT -p udp --dport 53 -j clash_dns
	iptables -t nat -F clash_dns >/dev/null 2>&1
	iptables -t nat -X clash_dns >/dev/null 2>&1
	#udp
	#转发UDP流量到clash端口
	iptables -t mangle -D merlinclash -d 192.168.2.1 -j RETURN
	iptables -t mangle -D merlinclash -p udp -j TPROXY --on-port "$proxy_port" --tproxy-mark 0x01/0x01
	iptables -t mangle -D merlinclash -p udp -j TPROXY --on-port "$proxy_port" --tproxy-mark 0x07
	#透明代理UDP流量到clash mangle链
	iptables -t mangle -D PREROUTING -p udp -j merlinclash
	iptables -t mangle -D PREROUTING -p udp -i $bridge -j merlinclash

	iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to 23453
	iptables -t nat -D OUTPUT -p tcp -d 198.18.0.0/16 -j REDIRECT --to-port "$proxy_port"
	iptables -t nat -D PREROUTING -p udp -s $(get_lan_cidr) --dport 53 -j DNAT --to $lan_ipaddr >/dev/null 2>&1
	iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 23453
	iptables -t nat -D PREROUTING -p udp --dport 53 -d $lan_ipaddr -j DNAT --to-destination $lan_ipaddr:23453
	
	iptables -t mangle -F merlinclash >/dev/null 2>&1 && iptables -t mangle -X merlinclash >/dev/null 2>&1
	
	iptables -t nat -F merlinclash >/dev/null 2>&1 && iptables -t nat -X merlinclash >/dev/null 2>&1
	#echo_date 删除ip route规则.
	ip rule del fwmark 1 lookup 100
	ip route del local default dev lo table 100
	#ip rule del fwmark 0x07 table 310
	#ip route del local 0.0.0.0/0 dev lo table 310
	echo_date 清除iptables规则完毕... >> $LOG_FILE
}
detect() {
	echo_date "检测jffs2脚本是否开启"
	local MODEL=$(nvram get productid)
	# 检测jffs2脚本是否开启，如果没有开启，将会影响插件的自启和DNS部分（dnsmasq.postconf）
	#if [ "$MODEL" != "GT-AC5300" ];then
	# 判断为非官改固件的，即merlin固件，需要开启jffs2_scripts，官改固件不需要开启
	if [ -z "$(nvram get extendno | grep koolshare)" ]; then
		if [ "$(nvram get jffs2_scripts)" != "1" ]; then
			echo_date "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			echo_date "+   发现你未开启Enable JFFS custom scripts and configs选项！        +"
			echo_date "+  【软件中心】和【MerlinClash】插件都需要此项开启才能正常使用！！  +"
			echo_date "+   请前往【系统管理】- 【系统设置】去开启，并重启路由器后重试！！  +"
			echo_date "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			close_in_five
		fi
	fi
}
close_in_five() {
	echo_date "插件将在5秒后自动关闭！！"
	local i=5
	while [ $i -ge 0 ]; do
		sleep 1s
		echo_date $i
		let i--
	done
	dbus set merlinclash_enable="0"
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		sh /koolshare/scripts/clash_unblockneteasemusic.sh stop
	fi
	stop_config >/dev/null

	echo_date "插件已关闭！！"
	echo_date ======================= Merlin Clash ========================
	unset_lock
	exit
}
#自定规则20200621
check_rule() {	
	# acl_nu 获取已存数据序号
	acl_nu=$(dbus list merlinclash_acl_type_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	num=0
	if [ -n "$acl_nu" ]; then
		for acl in $acl_nu; do
			type=$(eval echo \$merlinclash_acl_type_$acl)
			#ipaddr_hex=$(echo $ipaddr | awk -F "." '{printf ("0x%02x", $1)} {printf ("%02x", $2)} {printf ("%02x", $3)} {printf ("%02x\n", $4)}')
			content=$(eval echo \$merlinclash_acl_content_$acl)
			lianjie=$(eval echo \$merlinclash_acl_lianjie_$acl)
			type=$(decode_url_link $type)
			content=$(decode_url_link $content)
			lianjie=$(decode_url_link $lianjie)
			type=$(urldecode $type)
			content=$(urldecode $content)
			lianjie=$(urldecode $lianjie)
			#写入自定规则到当前配置文件
			num1=$(($num+1))
			rules_line=$(sed -n -e '/^rules:/=' $yamlpath)
			echo_date "写入第$num1条自定规则到当前配置文件" >> $LOG_FILE
			
			sed "$rules_line a \ \ -\ $type,$content,$lianjie" -i $yamlpath
			let num++
		done
	else
		echo_date "没有自定规则" >> $LOG_FILE	
	fi
	dbus remove merlinclash_acl_type
	dbus remove merlinclash_acl_content
	dbus remove merlinclash_acl_lianjie
	#格式化文本,避免rules:规则 - 未对齐而报错 -20200727
	sed -i '/^rules:/,/^port:/s/^[][ ]*- /  - /g' $yamlpath
	#格式化文本,避免proxies:节点 - 未对齐而报错 -20200727
	#aa=$(sed -n "/^proxies:/,/^proxy/p" $yamlpath | grep "\- name")
	#纯json格式，进行proxies:节点格式化
	#if [ -z "$aa" ]; then
	#	sed -i '/^proxies:/,/^proxy/s/^[][ ]*- /  - /g' $yamlpath
	#fi
}
#自定义容差值20200920
set_Tolerance(){
	if [ "$merlinclash_urltestTolerance_cbox" == "1" ]; then
		
		tolerance=$merlinclash_urltestTolerancesel
		echo_date "自定义延迟容差值:$tolerance" >> $LOG_FILE
		sed -i "s/tolerance: 100/tolerance: $tolerance/g" $yamlpath
	else
		echo_date "未定义延迟容差值，保持默认" >> $LOG_FILE
		
	fi	
}
#设备绕行20200721
lan_bypass(){
	# deivce_nu 获取已存数据序号
	echo_date ---------------------- 设备绕行检查区 开始 ------------------------ >> $LOG_FILE
	echo_date "【检查是否存在设备绕行】" >> $LOG_FILE
	device_nu=$(dbus list merlinclash_device_ip_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	num=0
	if [ -n "$device_nu" ]; then
		echo_date "【已设置设备绕行，将写入iptables】" >> $LOG_FILE
		#20200911新增链表 +++++++
		#iptables -t nat -N merlinclash_bypass
		#iptables -t mangle -N merlinclash_bypass
		
		#20200911新增链表 +++++++
		for device in $device_nu; do
			ip=$(eval echo \$merlinclash_device_ip_$device)
			name=$(eval echo \$merlinclash_device_name_$device)
			#20200920 新增模式处理
			mode=$(eval echo \$merlinclash_device_mode_$device)
			name=$(decode_url_link $name)
			ip=$(decode_url_link $ip)
			mode=$(decode_url_link $mode)
			echo_date "绕行设备名为【$name】,IP为【$ip】,模式为【$mode】"
			if [ "$mode" == "M模式" ]; then
				
				#写入绕行规则到iptables
				iptables -t nat -I merlinclash -s $ip/32 -j RETURN
				iptables -t mangle -I merlinclash -s $ip/32 -j RETURN
			fi
			if [ "$mode" == "P模式" ]; then
				iptables -t nat -I PREROUTING -s $ip/32 -j RETURN
  				iptables -t mangle -I PREROUTING -s $ip/32 -j RETURN	
			fi
			#iptables -t nat -I PREROUTING -s $ip/32 -j RETURN
  			#iptables -t mangle -I PREROUTING -s $ip/32 -j RETURN	
		done
	else
		echo_date "没有设置设备绕行" >> $LOG_FILE	
	fi
	dbus remove merlinclash_device_ip
	dbus remove merlinclash_device_name
	dbus remove merlinclash_device_mode
	echo_date ---------------------- 设备绕行检查区 结束 ------------------------ >> $LOG_FILE
}
#20200816复用为自定义host
start_host(){
	#host_nu=$(dbus list merlinclash_host_hostname_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	#hsnum=0
	#if [ -n "$host_nu" ] ; then
		#重写到/koolshare/merlinclash/yaml_basic/host.yaml中
	#	echo_date "检查到已配置自定义host，进行处理" >> $LOG_FILE
	#	for host in $host_nu; do
	#		name=$(eval echo \$merlinclash_host_hostname_$host)
	#		add=$(eval echo \$merlinclash_host_address_$host)
	#		num1=$(($num+1))
	#		host_line=$(sed -n -e '/^hosts:/=' $yamlpath)
	#		echo_date "写入第$num1条自定host到当前配置文件" >> $LOG_FILE
	#		sed "$host_line a \ \ $name: $add" -i $yamlpath
	#		let num++
	#	done		
	#else
	#	echo_date "未配置host" >> $LOG_FILE
	#fi
	#dbus remove merlinclash_host_hostname
	#dbus remove merlinclash_host_address
	
	host=$merlinclash_host_content1
	host_tmp=$merlinclash_host_content1_tmp
	#echo_date "$host"
	#echo_date "$host_tmp"
	#新增中间值比较
	if [ "$host" != "$host_tmp" ]; then
		echo_date "检测到host区值变化" >> $LOG_FILE
		#echo_date $host >> $LOG_FILE
		host=$(decode_url_link $host);
		echo -e "$host" > $hostsyaml
		#删除空行
		sed -i '/^ *$/d' $hostsyaml
		dbus set merlinclash_host_content1_tmp=$merlinclash_host_content1
	fi
	#用yq处理router.asus.com的值 修改router.asus.com ip地址为当前路由lanip
	router_tmp=$(yq r /koolshare/merlinclash/yaml_basic/hosts.yaml hosts.[router.asus.com])
	echo_date "router.asus.com值:$router_tmp" >> $LOG_FILE
	if [ -n "$router_tmp" ] && [ "$router_tmp" != "$lan_ipaddr" ]; then
		echo_date "修正router.asus.com值为路由LANIP" >> $LOG_FILE
		yq w -i $hostsyaml "hosts.[router.asus.com]" $lan_ipaddr
	fi
	rm -rf /tmp/upload/host_yaml.txt
	ln -sf $hostsyaml /tmp/upload/host_yaml.txt

	sed -i '$a' $yamlpath
	cat $hostsyaml >> $yamlpath

	echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
    echo_date "             +               hosts处理完毕           +" >> $LOG_FILE
    echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
}
start_remark(){
	/bin/sh /koolshare/scripts/clash_node_mark.sh remark
}

start_kcp(){
	# kcp_nu 获取已存数据序号

	kcp_nu=$(dbus list merlinclash_kcp_lport_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	kcpnum=0
	if [ -n "$kcp_nu" ] && [ "$merlinclash_kcpswitch" == "1" ]; then
		echo_date "检查到KCP开启且有KCP配置，将启动KCP加速" >> $LOG_FILE
		for kcp in $kcp_nu; do
			lport=$(eval echo \$merlinclash_kcp_lport_$kcp)
			server=$(eval echo \$merlinclash_kcp_server_$kcp)
			port=$(eval echo \$merlinclash_kcp_port_$kcp)
			param=$(eval echo \$merlinclash_kcp_param_$kcp)
			#根据传入值启动kcp进程
			kcpnum1=$(($kcpnum+1))
			echo_date "启动第$kcpnum1个kcp进程" >> $LOG_FILE
			/koolshare/bin/client_linux_arm64 -l :$lport -r $server:$port $param >/dev/null 2>&1 &
			local kcppid
			kcppid=$(pidof client_linux_arm64)
			if [ -n "$kcppid" ];then
				echo_date "kcp进程启动成功，pid:$kcppid! "
			else
				echo_date "kcp进程启动失败！"
			fi
			let kcpnum++
		done
	else
		echo_date "没有打开KCP开关或者不存在KCP设置，不启动KCP加速" >> $LOG_FILE
		kcp_process=$(pidof client_linux_arm64)
		if [ -n "$kcp_process" ]; then
			echo_date "关闭残留KCP协议进程"... >> $LOG_FILE
			killall client_linux_arm64 >/dev/null 2>&1
		fi	
	fi
	dbus remove merlinclash_kcp_lport
	dbus remove merlinclash_kcp_server
	dbus remove merlinclash_kcp_port
	dbus remove merlinclash_kcp_param	
}
set_sys() {
	# set_ulimit
	ulimit -n 16384
	echo 1 >/proc/sys/vm/overcommit_memory

	# more entropy
	# use command `cat /proc/sys/kernel/random/entropy_avail` to check current entropy
	echo_date "启动haveged，为系统提供更多的可用熵！"
	haveged_c -w 1024 >/dev/null 2>&1	
}
creat_ipset() {
	echo_date 开始创建ipset名单
	ipset -! create merlinclash_white nethash && ipset flush merlinlclash_white
}

load_nat() {
	nat_ready=$(iptables -t nat -L PREROUTING -v -n --line-numbers | grep -v PREROUTING | grep -v destination)
	i=120
	until [ -n "$nat_ready" ]; do
		i=$(($i - 1))
		if [ "$i" -lt 1 ]; then
			echo_date "错误：不能正确加载nat规则!" >> $LOG_FILE
			close_in_five
		fi
		sleep 1s
		nat_ready=$(iptables -t nat -L PREROUTING -v -n --line-numbers | grep -v PREROUTING | grep -v destination)
	done
	echo_date "加载nat规则!" >> $LOG_FILE
	sleep 1s
	apply_nat_rules3
	#chromecast
}
add_white_black_ip() {
    # black ip/cidr
    #ip_tg="149.154.0.0/16 91.108.4.0/22 91.108.56.0/24 109.239.140.0/24 67.198.55.0/24"
    #for ip in $ip_tg; do
    #    ipset -! add koolclash_black $ip >/dev/null 2>&1
    #done

    # white ip/cidr
    echo_date '应用局域网 IP 白名单'
    ip_lan="0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/4 $lan_ipaddr"
    for ip in $ip_lan; do
        ipset -! add merlinclash_white $ip >/dev/null 2>&1
    done

    #if [ ! -z $koolclash_firewall_whiteip_base64 ]; then
    #   ip_white=$(echo $koolclash_firewall_whiteip_base64 | base64_decode | sed '/\#/d')
    #    echo_date '应用外网目标 IP/CIDR 白名单'
    #    for ip in $ip_white; do
    #        ipset -! add koolclash_white $ip >/dev/null 2>&1
    #    done
    #fi
}
load_tproxy() {
	MODULES="xt_TPROXY xt_socket xt_comment"
	OS=$(uname -r)
	# load Kernel Modules
	echo_date 加载TPROXY模块，用于udp转发... >> $LOG_FILE
	checkmoduleisloaded() {
		if lsmod | grep $MODULE &>/dev/null; then return 0; else return 1; fi
	}

	for MODULE in $MODULES; do
		if ! checkmoduleisloaded; then
			insmod /lib/modules/${OS}/kernel/net/netfilter/${MODULE}.ko
		fi
	done

	modules_loaded=0

	for MODULE in $MODULES; do
		if checkmoduleisloaded; then
			modules_loaded=$((j++))
		fi
	done

	if [ "$modules_loaded" -ne "2" ]; then
		echo "One or more modules are missing, only $((modules_loaded + 1)) are loaded. Can't start." >> $LOG_FILE
		close_in_five
	fi
}
apply_nat_rules3() {
	proxy_port=23457
	#ssh_port=22
	
	dem2=$(cat $yamlpath | grep "enhanced-mode:" | awk -F "[: ]" '{print $5}')
	echo_date "开始写入iptable规则" >> $LOG_FILE
	
	

	if [ "$merlinclash_dnsplan" == "rh" ] || [ "$merlinclash_dnsplan" == "rhp" ] || [ "$dem2" == "redir-host" ];then
		# ports redirect for clash except port 22 for ssh connection
		echo_date "dns方案是$merlinclash_dnsplan;配置文件dns方案是$dem2" >> $LOG_FILE
		echo_date "lan_ip是$lan_ipaddr" >> $LOG_FILE
		iptables -t nat -A PREROUTING -p tcp --dport $ssh_port -j ACCEPT
		#new
		iptables -t nat -N merlinclash
		iptables -t nat -A merlinclash -d 192.168.0.0/16 -j RETURN
		iptables -t nat -A merlinclash -d 0.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 10.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 127.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 169.254.0.0/16 -j RETURN
		iptables -t nat -A merlinclash -d 172.16.0.0/12 -j RETURN
		iptables -t nat -A merlinclash -d 224.0.0.0/4 -j RETURN
		iptables -t nat -A merlinclash -d 240.0.0.0/4 -j RETURN

		#redirect to Clash
		iptables -t nat -A merlinclash -p tcp -j REDIRECT --to-ports $proxy_port
		#iptables -t nat -A PREROUTING -j merlinclash
		iptables -t nat -A PREROUTING -p tcp -j merlinclash
		#DNS
		if [ "$merlinclash_dnsplan" == "rh" ]; then
			iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 23453
		fi
		if [ "$merlinclash_dnsplan" == "rhp" ]; then
			iptables -t nat -N clash_dns >/dev/null 2>&1
			iptables -t nat -F clash_dns >/dev/null 2>&1
			iptables -t nat -A clash_dns -p udp -j REDIRECT --to-ports 23453
			iptables -t nat -A PREROUTING -p udp --dport 53 -j clash_dns
			iptables -t nat -A OUTPUT -p udp --dport 53 -j clash_dns
		fi
		
	fi
	#fake-ip rule
	if [ "$merlinclash_dnsplan" == "fi" ] || [ "$dem2" == "fake-ip" ];then
		echo_date "dns方案是$merlinclash_dnsplan;配置文件dns方案是$dem2" >> $LOG_FILE
		echo_date "lan_ip是$lan_ipaddr" >> $LOG_FILE
		# ports redirect for clash except port 22 for ssh connection
		iptables -t nat -A PREROUTING -p tcp --dport $ssh_port -j ACCEPT
		#new
		iptables -t nat -N merlinclash
		iptables -t nat -A merlinclash -d 192.168.0.0/16 -j RETURN
		iptables -t nat -A merlinclash -d 10.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 0.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 127.0.0.0/8 -j RETURN
		iptables -t nat -A merlinclash -d 169.254.0.0/16 -j RETURN
		iptables -t nat -A merlinclash -d 172.16.0.0/12 -j RETURN
		iptables -t nat -A merlinclash -d 224.0.0.0/4 -j RETURN
		iptables -t nat -A merlinclash -d 240.0.0.0/4 -j RETURN

		#redirect to Clash
		iptables -t nat -A merlinclash -p tcp -j REDIRECT --to-ports $proxy_port
		iptables -t nat -A PREROUTING -p tcp -j merlinclash
		
		
		# fake-ip rules
		#iptables -t nat -A OUTPUT -p tcp -m mark --mark "$ip_prefix_hex" -d 198.18.0.0/16 -j RETURN
		#iptables -t nat -A OUTPUT -p tcp -d 198.18.0.0/16 -j REDIRECT --to-ports $proxy_port
		#DNS
		iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j DNAT --to-destination $lan_ipaddr:23453			
	fi

	if [ "$merlinclash_udpr" == "1" ]; then
		echo_date "检测到开启udp转发，将创建相关iptable规则" >> $LOG_FILE
		# udp
		load_tproxy
		# 设置策略路由
		#modprobe xt_TPROXY
		#ip rule add fwmark 0x07 table 310
		
		#ip route add local 0.0.0.0/0 dev lo table 310
		ip rule add fwmark 1 lookup 100
		ip route add local default dev lo table 100
		iptables -t mangle -N merlinclash
		iptables -t mangle -F merlinclash

		#绕过内网
		
		#iptables -t mangle -A merlinclash -d 192.168.0.0/16 -j RETURN
		iptables -t mangle -A merlinclash -d 192.168.0.0/16 -p tcp -j RETURN
		iptables -t mangle -A merlinclash -d 192.168.0.0/16 -p udp ! --dport 53 -j RETURN
		iptables -t mangle -A merlinclash -d 192.168.0.0/16 -p udp ! --dport 23453 -j RETURN
		iptables -t mangle -A merlinclash -d 10.0.0.0/8 -j RETURN
		iptables -t mangle -A merlinclash -d 0.0.0.0/8 -j RETURN
		iptables -t mangle -A merlinclash -d 127.0.0.0/8 -j RETURN
		iptables -t mangle -A merlinclash -d 169.254.0.0/16 -j RETURN
		iptables -t mangle -A merlinclash -d 172.16.0.0/12 -j RETURN
		iptables -t mangle -A merlinclash -d 224.0.0.0/4 -j RETURN
		iptables -t mangle -A merlinclash -d 240.0.0.0/4 -j RETURN	
		#转发UDP流量到clash端口
		iptables -t mangle -A merlinclash -p udp -j TPROXY --on-port "$proxy_port" --tproxy-mark 0x01/0x01
		#透明代理UDP流量到clash mangle链
		iptables -t mangle -A PREROUTING -p udp -i $bridge -j merlinclash
		#iptables -t mangle -A PREROUTING -p udp -j merlinclash
		

	else
		echo_date "【检测到udp转发未开启，进行下一步】" >> $LOG_FILE

	fi
	#设备绕行
	lan_bypass

	if [ "$merlinclash_dashboardswitch" == "1" ]; then
		iptables -I INPUT -p tcp --dport 9990 -j ACCEPT
	else
		iptables -D INPUT -p tcp --dport 9990 -j ACCEPT
	fi
	echo_date "iptable规则创建完成" >> $LOG_FILE
}
restart_dnsmasq() {
    # Restart dnsmasq
    echo_date "重启 dnsmasq..." >> $LOG_FILE
    service restart_dnsmasq >/dev/null 2>&1
}

start_clash(){
	echo_date "启用$yamlname YAML配置" >> $LOG_FILE
	ln -sf $yamlpath /tmp/upload/view.txt 
	#/koolshare/bin/clash -d /koolshare/merlinclash/ -f $yamlpath >/dev/null 2>/tmp/upload/clash_error.log &
	/koolshare/bin/clash -d /koolshare/merlinclash/ -f $yamlpath 1>/tmp/clash_run.log  2>&1 &
	#检查clash进程
	if [ "$merlinclash_check_delay_cbox" == "1" ]; then
		
		delaytime=$merlinclash_check_delay_time
		echo_date "延迟检查clash启动日志时间:$delaytime秒" >> $LOG_FILE
		sleep $delaytime
	else
		echo_date "延迟检查clash启动日志时间:2秒" >> $LOG_FILE
		sleep 2s
	fi
	

	if [ ! -z "$(pidof clash)" -a ! -z "$(netstat -anp | grep clash)" -a ! -n "$(grep "Parse config error" /tmp/clash_run.log)" ] ; then
		echo_date "Clash 进程启动成功！(PID: $(pidof clash))"
		rm -rf /tmp/upload/*.yaml

	else
		echo_date "Clash 进程启动失败！请检查配置文件是否存在问题，即将退出"
		echo_date "失败原因："
		error1=$(cat /tmp/clash_run.log | grep -oE "Parse config error.*")
		error2=$(cat /tmp/clash_run.log | grep -oE "clashconfig.sh.*")
		error3=$(cat /tmp/clash_run.log | grep -oE "illegal instruction.*")
		if [ -n "$error1" ]; then
    		echo_date $error1 >> $LOG_FILE		
		elif [ -n "$error2" ]; then
    		echo_date $error2 >> $LOG_FILE
		elif [ -n "$error3" ]; then
    		echo_date $error3 >> $LOG_FILE
		fi
		close_in_five
	fi
}

check_yaml(){
	#配合自定规则，此处修改为每次都从BAK恢复原版文件来操作-20200629
	#每次从/koolshare/merlinclash/yaml 复制一份上传的 上传文件名.yaml 使用
	echo_date "从yaml_bak恢复初始文件" >> $LOG_FILE
	cp -rf /koolshare/merlinclash/yaml_bak/$yamlname.yaml $yamlpath
	if [ -f "$yamlpath" ]; then
		echo_date "检查到Clash配置文件存在！选中的配置文件是【$yamlname】" >> $LOG_FILE
		#echo_date "将标准头部文件复制一份到/tmp/" >>"$LOG_FILE"
		#cp -rf /koolshare/merlinclash/yaml/head.yaml /tmp/head.yaml >/dev/null 2>&1 &
		#sleep 1s
		#不再重复处理 20200721+++++++++++++++++++++++++++++++++++
		#不再重复处理 20200721--------------------------------
	else
		echo_date "文件丢失，没有找到上传的配置文件！请先上传您的配置文件！" >> $LOG_FILE
		echo_date "...MerlinClash！退出中..." >> $LOG_FILE
		close_in_five
	fi
}
check_ss(){
	
	pid_ss=$(pidof ss-redir)
	pid_rss=$(pidof rss-redir)
	pid_v2ray=$(pidof v2ray)
	pid_trojan=$(pidof trojan)
	pid_trojango=$(pidof trojan-go)
	pid_koolgame=$(pidof koolgame)
	if [ -n "$pid_ss" ] || [ -n "$pid_v2ray" ] || [ -n "$pid_trojan" ] || [ -n "$pid_trojango" ] || [ -n "$pid_koolgame" ] || [ -n "$pid_rss" ]; then
    	echo_date "检测到【科学上网】插件启用中，请先关闭该插件，再运行MerlinClash！"
		echo_date "...MerlinClash！退出中..."
		close_in_five 	
    else
	    echo_date "没有检测到冲突插件，准备开启MerlinClash！"
	fi
}

get_lan_cidr() {
	local netmask=$(nvram get lan_netmask)
	local x=${netmask##*255.}
	set -- 0^^^128^192^224^240^248^252^254^ $(((${#netmask} - ${#x}) * 2)) ${x%%.*}
	x=${1%%$3*}
	suffix=$(($2 + (${#x} / 4)))
	#prefix=`nvram get lan_ipaddr | cut -d "." -f1,2,3`
	echo $lan_ipaddr/$suffix
}

#yaml面板secret段重赋值
start_dashboard(){
	#secret=$(cat $yamlpath | awk '/secret:/{print $2}' | sed 's/"//g')
	sed -i "s/^secret: \"clash\"/secret: \"$merlinclash_dashboard_secret\"/g" $yamlpath
	echo_date 修改管理面板密码为：$merlinclash_dashboard_secret
}

check_dnsplan(){
	echo_date "当前dns方案是$merlinclash_dnsplan"
	#插入换行符免得出错
	sed -i '$a' $yamlpath
	case $merlinclash_dnsplan in
rh)
	#默认方案
	echo_date "采用配置文件的默认DNS方案Redir-Host" >> $LOG_FILE
	cat /koolshare/merlinclash/yaml_dns/redirhost.yaml >> $yamlpath
	;;
#rh)
	#redir-host方案，将/koolshare/merlinclash/上传文件名.yaml 跟 redirhost.yaml 合并
#	echo_date "采用Redir-Host的DNS方案" >> $LOG_FILE

#	cat /koolshare/merlinclash/yaml/redirhost.yaml >> $yamlpath
#	;;
rhp)
	#redir-host-plus方案，将/koolshare/merlinclash/上传文件名.yaml 跟 rhplus.yaml 合并
	echo_date "采用Redir-Host-Plus的DNS方案" >> $LOG_FILE

	cat /koolshare/merlinclash/yaml_dns/rhplus.yaml >> $yamlpath
	;;
fi)
	#fake-ip方案，将/koolshare/merlinclash/上传文件名.yaml 跟 fakeip.yaml 合并
	echo_date "采用Fake-ip的DNS方案" >> $LOG_FILE 

	cat /koolshare/merlinclash/yaml_dns/fakeip.yaml >> $yamlpath
	;;
esac

	#20200623
	if [ "$merlinclash_enable" == "1" ] && [ "$merlinclash_ipv6switch" == "1" ];then
		echo_date "检测到开启ipv6，将为你设置dns.ipv6为true" >> $LOG_FILE
		
		#查找行数
		ipv6_line=$(cat $yamlpath | grep -n "ipv6:" | awk -F ":" '{print $1}')
		#删除行，再重写
		sed -i "$ipv6_line d" $yamlpath
		sed "$ipv6_line a \ \ ipv6: true" -i $yamlpath
	else
		echo_date "关闭clash或未开启ipv6，将为你设置dns.ipv6为false" >> $LOG_FILE
		
		ipv6_line=$(cat $yamlpath | grep -n "ipv6:" | awk -F ":" '{print $1}')
		#删除行，再重写
		sed -i "$ipv6_line d" $yamlpath
		sed "$ipv6_line a \ \ ipv6: false" -i $yamlpath
	fi

}
stop_config(){
	echo_date 触发脚本stop_config >> $LOG_FILE
	#ss_pre_stop
	# now stop first
	echo_date ======================= MERLIN CLASH ======================== >> $LOG_FILE
	echo_date
	echo_date --------------------------- 启动 ---------------------------- >> $LOG_FILE
	#stop_status 
	echo_date ---------------------- 结束相关进程-------------------------- >> $LOG_FILE
	kill_cron_job
	if [ -f "/koolshare/bin/UnblockNeteaseMusic" ]; then
		sh /koolshare/scripts/clash_unblockneteasemusic.sh stop
	fi
	restart_dnsmasq
	kill_process
	echo_date -------------------- 相关进程结束完毕 -----------------------  >> $LOG_FILE
	echo_date ----------------------清除iptables规则----------------------- >> $LOG_FILE
	flush_nat
	#20200727

}
check_unblockneteasemusic(){
	if [ "$merlinclash_enable" == "1" ]; then
		if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
			echo_date "检测到开启网易云音乐本地解锁功能，开始处理" >> $LOG_FILE	

			sh /koolshare/scripts/clash_unblockneteasemusic.sh restart
			sleep 1s
			#write_unblock
		else
			echo_date "网易云音乐本地解锁未开启" >> $LOG_FILE
			sh /koolshare/scripts/clash_unblockneteasemusic.sh stop					
		fi
	fi
}
write_unblock(){
	ubm_process=$(pidof UnblockNeteaseMusic);
	if [ -n "$ubm_process" ]; then			
	#获取proxies跟rules行号
		proxy_line=$(sed -n -e '/^proxies:/=' $yamlpath)
       	rules_line=$(sed -n -e '/^rules:/=' $yamlpath)
		#ubm="\ \ - {name: 网易云解锁WINDOWS/ANDORID, server: music.desperadoj.com, port: 30001, type: ss, cipher: aes-128-gcm, password: desperadoj.com_free_proxy_x80j}"
		ubmlocal="\ \ - {name: 网易云解锁-本地, server: 127.0.0.1, port: 5200, type: http}"
		#ubm2="\ \ - {name: 网易云解锁MAC/IOS, server: music.desperadoj.com, port: 30003, type: ss, cipher: aes-128-gcm, password: desperadoj.com_free_proxy_x80j}"
		#写入proxies
		echo_date "写入网易云解锁的proxy跟proxy-group" 	>> $LOG_FILE
		#sed "$proxy_line a$ubm2" -i $yamlpath
		#sed "$proxy_line a$ubm" -i $yamlpath
		sed "$proxy_line a$ubmlocal" -i $yamlpath
		#写入proxy-groups
		pg1="\ \ - name: 🎵 Netease Music"
		pg2="\ \ \ \ type: select"
		pg3="\ \ \ \ proxies:"
		pg7="\ \ \ \ \ \ - 网易云解锁-本地"
		pg5="\ \ \ \ \ \ - DIRECT"
		sed "$rules_line a$pg1" -i $yamlpath
                
		let rules_line=$rules_line+1
		sed "$rules_line a$pg2" -i $yamlpath
             
		let rules_line=$rules_line+1
		sed "$rules_line a$pg3" -i $yamlpath
              
		let rules_line=$rules_line+1
		sed "$rules_line a$pg7" -i $yamlpath
              
		let rules_line=$rules_line+1
		sed "$rules_line a$pg5" -i $yamlpath
               
				#写入网易云的clash rule部分  格式:  - "DOMAIN-SUFFIX,acl4ssr,\U0001F3AF 全球直连"				
		echo_date 写入网易云的clash rule部分 >> $LOG_FILE
		rules_line=$(sed -n -e '/^rules:/=' $yamlpath)
               
		sed "$rules_line a \ \ -\ IP-CIDR,223.252.199.67/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,223.252.199.66/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,193.112.159.225/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,118.24.63.156/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,115.236.121.3/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,115.236.121.1/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,115.236.118.33/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,112.13.122.1/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,112.13.119.17/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,103.126.92.133/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,103.126.92.132/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,101.71.154.241/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.238.29/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.181.35/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.160.197/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.160.195/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.181.60/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.181.38/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.179.214/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.21.14/31,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,47.100.127.239/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,45.254.48.1/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,42.186.120.199/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ IP-CIDR,39.105.63.80/32,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,nstool.netease.com,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,hz.netease.com,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,mam.netease.com,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,interface3.music.163.com,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,interface.music.163.com,🎵 Netease Music" -i $yamlpath
				
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,apm.music.163.com,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,apm3.music.163.com,🎵 Netease Music" -i $yamlpath 
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,api.iplay.163.com,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,music.163.com,🎵 Netease Music" -i $yamlpath
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,163yun.com,🎵 Netease Music" -i $yamlpath	
	else
		echo_date "网易云音乐解锁无法启动" >> $LOG_FILE
		dbus set $merlinclash_unblockmusic_enable="0";
	fi
}
auto_start() {
	echo_date "创建开机/iptable重启任务" >> $LOG_FILE
	[ ! -L "/koolshare/init.d/S99merlinclash.sh" ] && ln -sf /koolshare/merlinclash/clashconfig.sh /koolshare/init.d/S99merlinclash.sh
	[ ! -L "/koolshare/init.d/N99merlinclash.sh" ] && ln -sf /koolshare/merlinclash/clashconfig.sh /koolshare/init.d/N99merlinclash.sh
}

apply_mc() {
	# router is on boot
	WAN_ACTION=`ps|grep /jffs/scripts/wan-start|grep -v grep`
	
	# now stop first
	echo_date ======================= MERLIN CLASH ======================== >> $LOG_FILE
	echo_date --------------------- 检查是否存冲突插件 ----------------------- >> $LOG_FILE
	check_ss
	echo_date ---------------------- 重启dnsmasq -------------------------- >> $LOG_FILE
	restart_dnsmasq
	echo_date ----------------------- 结束相关进程--------------------------- >> $LOG_FILE
	kill_process
	echo_date --------------------- 相关进程结束完毕 ------------------------ >> $LOG_FILE
	kill_cron_job
	echo_date -------------------- 检查配置文件是否存在 --------------------- >> $LOG_FILE
	check_yaml
	echo_date ""
	echo_date -------------------- 添加host区 开始-------------------------- >> $LOG_FILE
	start_host
	echo_date -------------------- 添加host区 结束-------------------------- >> $LOG_FILE
	echo_date ""
	echo_date ------------------------ 确认DNS方案 -------------------------- >> $LOG_FILE
	check_dnsplan
	echo_date -------------------- 自定义规则检查区 开始-------------------------- >> $LOG_FILE
	check_rule
	echo_date -------------------- 自定义规则检查区 结束-------------------------- >> $LOG_FILE
	echo_date ""
	echo_date -------------------- 自定义延迟容差值 开始-------------------------- >> $LOG_FILE
	set_Tolerance
	echo_date -------------------- 自定义延迟容差 结束-------------------------- >> $LOG_FILE
	echo_date ""
	# 清除iptables规则和ipset...
	echo_date --------------------- 清除iptables规则 开始------------------------ >> $LOG_FILE
	flush_nat
	echo_date --------------------- 清除iptables规则 结束------------------------ >> $LOG_FILE
	echo_date ""
	#echo_date -------------------- 面板定义区 开始-------------------------- >> $LOG_FILE
	start_dashboard
	#echo_date -------------------- 面板定义区 结束-------------------------- >> $LOG_FILE
	#echo_date ""
	echo_date --------------------- 网易云功能检查区 开始------------------------ >> $LOG_FILE
	check_unblockneteasemusic
	echo_date --------------------- 网易云功能检查区 结束------------------------ >> $LOG_FILE
	# 检测jffs2脚本是否开启
	detect
	# 启动haveged，为系统提供更多的可用熵！
	set_sys
	echo_date ---------------------- 启动插件相关功能 ------------------------ >> $LOG_FILE
	start_clash && echo_date "start_clash" >> $LOG_FILE
	#echo_date ------------------------ 节点记忆检查区 开始---------------------- >> $LOG_FILE 
	#start_host
	#echo_date ------------------------ 节点记忆检查区 结束---------------------- >> $LOG_FILE
	echo_date ------------------------ 恢复记忆节点 开始---------------------- >> $LOG_FILE 
	start_remark
	echo_date ------------------------ 恢复记忆节点 结束---------------------- >> $LOG_FILE
	echo_date ""
	echo_date --------------------- 创建iptables规则 开始------------------------ >> $LOG_FILE
	load_nat
	echo_date --------------------- 创建iptables规则 结束------------------------ >> $LOG_FILE
	echo_date ""
	#----------------------------------KCP进程--------------------------------
	echo_date ---------------------- KCP设置检查区 开始 ------------------------ >> $LOG_FILE
	start_kcp
	echo_date ---------------------- KCP设置检查区 结束 ------------------------ >> $LOG_FILE
	#----------------------------------应用节点记忆----------------------------
	restart_dnsmasq
	auto_start
	watchdog
	echo_date ---------------------- 节点后台记忆区 开始 ------------------------ >> $LOG_FILE
	write_setmark_cron_job
	echo_date ---------------------- 节点后台记忆区 结束 ------------------------ >> $LOG_FILE
	echo_date "" >>$LOG_FILE
	echo_date ---------------------- 定时订阅检查区 开始 ------------------------ >> $LOG_FILE
	write_regular_cron_job
	echo_date ---------------------- 定时订阅检查区 结束 ------------------------ >> $LOG_FILE
	echo_date "" >> $LOG_FILE
	echo_date ---------------------- 定时重启检查区 开始 ------------------------ >> $LOG_FILE
	write_clash_restart_cron_job
	echo_date ---------------------- 定时重启检查区 结束 ------------------------ >> $LOG_FILE
    echo_date "" >> $LOG_FILE
	echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
    echo_date "             +        管理面板：$lan_ipaddr:9990     +" >> $LOG_FILE
    echo_date "             +       Http代理：$lan_ipaddr:3333     +"  >> $LOG_FILE
    echo_date "             +      Socks代理：$lan_ipaddr:23456    +" >> $LOG_FILE
    echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
    echo_date "                     恭喜！开启MerlinClash成功！" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
	echo_date   "如果不能科学上网，请刷新设备dns缓存，或者等待几分钟再尝试" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
	echo_date ==================== 【MERLIN CLASH】 启动完毕 ==================== >> $LOG_FILE
}
restart_mc_quickly(){
	echo_date ----------------------- 结束相关进程--------------------------- >> $LOG_FILE
	kill_clash
	#kill_cron_job
	echo_date ---------------------- 启动插件相关功能 ------------------------ >> $LOG_FILE
	start_clash && echo_date "start_clash" >> $LOG_FILE
	echo_date ------------------------ 恢复记忆节点 开始---------------------- >> $LOG_FILE 
	start_remark
	echo_date ------------------------ 恢复记忆节点 结束---------------------- >> $LOG_FILE
	restart_dnsmasq
	#===load nat end===
	# 创建开机/IPT重启任务！
	auto_start
	#kill_setmark
	#watchdog
	#echo_date ---------------------- 节点后台记忆区 开始 ------------------------ >> $LOG_FILE
	#write_setmark_cron_job
	#echo_date ---------------------- 节点后台记忆区 结束 ------------------------ >> $LOG_FILE
	#echo_date "" >>$LOG_FILE
	#echo_date ---------------------- 定时订阅检查区 开始 ------------------------ >> $LOG_FILE
	#write_regular_cron_job
	#echo_date ---------------------- 定时订阅检查区 结束 ------------------------ >> $LOG_FILE
    echo_date "" >> $LOG_FILE
	echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
    echo_date "             +        管理面板：$lan_ipaddr:9990      +" >> $LOG_FILE
    echo_date "             +        Http代理：$lan_ipaddr:3333      +"  >> $LOG_FILE
    echo_date "             +       Socks代理：$lan_ipaddr:23456     +" >> $LOG_FILE
    echo_date "             ++++++++++++++++++++++++++++++++++++++++" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
    echo_date "                     恭喜！开启MerlinClash成功！" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
	echo_date   "如果不能科学上网，请刷新设备dns缓存，或者等待几分钟再尝试" >> $LOG_FILE
	echo_date "" >> $LOG_FILE
	echo_date ==================== 【MERLIN CLASH】 启动完毕 ==================== >> $LOG_FILE	
}

case $ACTION in
start)
	mkdir -p /tmp/lock
	logger "[软件中心]: 开机启动MerlinClash插件！"
	echo_date "[软件中心]: 开机启动MerlinClash插件！" >> $LOG_FILE

	#set_lock
	if [ "$merlinclash_enable" == "1" ]; then
		
		dbus get merlinclash_lockfile
		lcfiletmp=/tmp/lock/$merlinclash_lockfile.txt
		echo_date "前一进程锁文件:$lcfiletmp"  >> $LOG_FILE

		lc=$$	
		merlinclash_lockfile="$lc"
		dbus set merlinclash_lockfile="$merlinclash_lockfile"
		lcfile1=/tmp/lock/$lc.txt
		echo_date "触发重启任务pid:$lc"  >> $LOG_FILE
		
		echo_date "创建本重启进程锁文件${lcfile1}" >> $LOG_FILE 
		touch $lcfile1
		
		i=60

		echo_date "将本任务pid写入lockfile:$merlinclash_lockfile" >> $LOG_FILE
		echo $$ > ${lcfile1}

		while [ $i -ge 0 ]; do
			if [ -e ${lcfiletmp} ] && kill -0 `cat ${lcfiletmp}`; then 
				echo_date " $merlinclash_lockfile 锁进程中" >> $LOG_FILE
				echo $$ > ${lcfile1}
				sleep 5s
			else
				let i=0
				echo_date "上个重启进程文件锁解除" >> $LOG_FILE
			fi
			let i--
		done
		
		# 确保退出时，锁文件被删除 
		trap "rm -rf ${lcfile1}; exit" INT TERM EXIT 
		
		echo $$ > ${lcfile1} 
		echo_date "2次创建本重启进程锁文件${lcfile1}" >> $LOG_FILE
		apply_mc >>"$LOG_FILE"
	else
		logger "[软件中心]: MerlinClash插件未开启，不启动！"
		echo_date "[软件中心]: MerlinClash插件未开启，不启动！" >> $LOG_FILE
	fi
	rm -rf ${lcfile1} 
	#unset_lock
	;;
upload)
	move_config >>"$LOG_FILE"
	http_response 'success'
	;;
stop)
	set_lock
	stop_config
	echo_date >> $LOG_FILE
	echo_date 你已经成功关闭Merlin Clash~ >> $LOG_FILE
	echo_date See you again! >> $LOG_FILE
	echo_date >> $LOG_FILE
	echo_date ======================= Merlin Clash ======================== >> $LOG_FILE
	unset_lock
	;;
restart)
	set_lock
	apply_mc
	echo_date >> $LOG_FILE
	echo_date "Across the Great Wall we can reach every corner in the world!" >> $LOG_FILE
	echo_date >> $LOG_FILE
	echo_date ======================= Merlin Clash ======================== >> $LOG_FILE
	unset_lock
	;;
quicklyrestart)
	set_lock
	restart_mc_quickly
	echo_date >> $LOG_FILE
	echo_date "Across the Great Wall we can reach every corner in the world!" >> $LOG_FILE
	echo_date >> $LOG_FILE
	echo_date ======================= Merlin Clash ======================== >> $LOG_FILE
	unset_lock
	;;
start_nat)
	#set_lock
	mkdir -p /tmp/lock

	echo_date "================= Merlin Clash Start Nat Begin =================" >> $LOG_FILE
	dbus get merlinclash_lockfile
	lcfiletmp=/tmp/lock/$merlinclash_lockfile.txt
	echo_date "前一进程锁文件:$lcfiletmp"  >> $LOG_FILE

	lc=$$	
	merlinclash_lockfile="$lc"
	dbus set merlinclash_lockfile="$merlinclash_lockfile"
	lcfile1=/tmp/lock/$lc.txt
	echo_date "触发重启任务pid:$lc"  >> $LOG_FILE
	
	echo_date "创建本重启进程锁文件${lcfile1}" >> $LOG_FILE 
	touch $lcfile1
	
	i=60

	echo_date "将本任务pid写入lockfile:$merlinclash_lockfile" >> $LOG_FILE
	echo $$ > ${lcfile1}
	#sleep 1s
	

	while [ $i -ge 0 ]; do
		if [ -e ${lcfiletmp} ] && kill -0 `cat ${lcfiletmp}`; then 
    		echo_date " $merlinclash_lockfile 锁进程中" >> $LOG_FILE
			#echo $$ > {$merlinclash_lockfile}_{$lc}.txt
			#echo_date "将当前进程id写入锁文件${lcfile1}" >> $LOG_FILE
			#echo $$ > ${lcfile1}
   			sleep 5s
		else
			let i=0
			echo_date "上个重启进程文件锁解除" >> $LOG_FILE
		fi
		let i--
	done
	
	# 确保退出时，锁文件被删除 
	trap "rm -rf ${lcfile1}; exit" INT TERM EXIT 
	
	echo $$ > ${lcfile1}
	echo_date "2次创建本重启进程锁文件${lcfile1}" >> $LOG_FILE 
	logger "[软件中心]: iptable发生变化，Merlin Clash nat重启！"
	echo_date "============= Merlin Clash iptable 重写开始=============" >> $LOG_FILE
	echo_date "[软件中心]: iptable发生变化，Merlin Clash nat重启！" >> $LOG_FILE
	sleep 1s
	if [ "$merlinclash_enable" == "1" ]; then	
		#初始化iptables，防止重复数据写入
		flush_nat	
		
		#写入网易云iptables
		if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
			sh /koolshare/scripts/clash_unblockneteasemusic.sh restart
		fi
		#写入clash iptables
		apply_nat_rules3
		echo_date "============= Merlin Clash iptable 重写完成=============" >> $LOG_FILE
	else
		logger "[软件中心]: MerlinClash插件未开启，不启动！"
		echo_date "[软件中心]: MerlinClash插件未开启，不启动！" >> $LOG_FILE
	fi
	#unset_lock
	# 删除锁文件 
	rm -rf ${lcfile1} 
	echo_date "================= Merlin Clash Start Nat END =================" >> $LOG_FILE
	;;
esac