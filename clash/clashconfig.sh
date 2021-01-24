#!/bin/bash

KSROOT=/koolshare
KSSCRIPTS=$KSROOT/scripts

# 配置环境
. $KSSCRIPTS/base.sh
eval "$(dbus export merlinclash_)"
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

UPLOAD_DIR=/tmp/upload
LOCK_DIR=/var/lock

LOG_FILE=$UPLOAD_DIR/merlinclash_log.txt
LOCK_FILE=$LOCK_DIR/merlinclash.lock

ROOT_DIR=$KSROOT/merlinclash
BASIC_DIR=$ROOT_DIR/yaml_basic
DNS_DIR=$ROOT_DIR/yaml_dns
USE_DIR=$ROOT_DIR/yaml_use
BAK_DIR=$ROOT_DIR/yaml_bak

# 配置文件名
CONFIG_NAME=$merlinclash_yamlsel
# 配置文件路径
CONFIG_FILE=$USE_DIR/$CONFIG_NAME.yaml
# 20200904 新增host.yaml处理
HOSTS_FILE=$BASIC_DIR/hosts.yaml
HEAD_FILE=$BASIC_DIR/head.yaml

# 提取配置认证码
secret=$(awk '/secret:/{print $2}' "$CONFIG_FILE" | sed 's/"//g')
# 提取配置监听端口
extctl_port=$(awk -F: '/external-controller/{print $3}' "$CONFIG_FILE")

chromecast_nu=""
lan_ipaddr=$(nvram get lan_ipaddr)
ip_prefix_hex=$(nvram get lan_ipaddr | awk -F "." '{printf ("0x%02x", $1)} {printf ("%02x", $2)} {printf ("%02x", $3)} {printf ("00/0xffffff00\n")}')
bridge=$(ifconfig | grep br | awk -F' ' '{print $1}')
sshd_port=$(nvram get sshd_port)
dashboard_port=9990

rm -rf $UPLOAD_DIR/clash_error.log
rm -rf $UPLOAD_DIR/dns_read_error.log

echo_log() {
	logger "$1"
	echo_date "$1" >>$LOG_FILE
}

#######################
# lock
#######################

set_lock() {
	exec 1000>"$LOCK_FILE"
	flock -x 1000
}

unset_lock() {
	flock -u 1000
	rm -rf "$LOCK_FILE"
}

#######################
# tproxy
#######################

load_tproxy() {
	# load Kernel Modules
	echo_date "加载TPROXY模块，用于udp转发..." >>$LOG_FILE

	local MODULES="xt_TPROXY xt_socket xt_comment"
	local OS=$(uname -r)

	for MODULE in $MODULES; do
		if ! (lsmod | grep -q "$MODULE"); then
			insmod "/lib/modules/$OS/kernel/net/netfilter/$MODULE.ko" &>/dev/null
		fi
	done

	local modules_loaded=0
	for MODULE in $MODULES; do
		if lsmod | grep -q "$MODULE"; then
			modules_loaded=$((modules_loaded + 1))
		fi
	done
	if [ "$modules_loaded" -ne "3" ]; then
		echo "One or more modules are missing, only $modules_loaded are loaded. Can't start." >>$LOG_FILE
		close_in_five
	fi
}

#######################
# route
#######################

apply_nat_rules3() {
	# see: https://lancellc.gitbook.io/clash/start-clash/clash-udp-tproxy-support#step-2-add-rules-in-iptable-linux-only

	local proxy_port=$(yq r "$CONFIG_FILE" 'redir-port')
	local enhanced_mode=$(yq r "$CONFIG_FILE" 'dns.enhanced-mode')

	{
		echo_date "开始写入iptable规则"
		echo_date "dns方案是：$merlinclash_dnsplan; 配置文件dns方案是：$enhanced_mode"
		echo_date "lan_ipaddr是：$lan_ipaddr"
	} >>$LOG_FILE

	#
	# tcp traffic

	iptables -t nat -N merlinclash
	iptables -t mangle -F merlinclash
	# return local addr
	iptables -t nat -A merlinclash -d 0.0.0.0/8 -j RETURN
	iptables -t nat -A merlinclash -d 10.0.0.0/8 -j RETURN
	iptables -t nat -A merlinclash -d 127.0.0.0/8 -j RETURN
	iptables -t nat -A merlinclash -d 169.254.0.0/16 -j RETURN
	iptables -t nat -A merlinclash -d 172.16.0.0/12 -j RETURN
	iptables -t nat -A merlinclash -d 192.168.0.0/16 -j RETURN
	iptables -t nat -A merlinclash -d 224.0.0.0/4 -j RETURN
	iptables -t nat -A merlinclash -d 240.0.0.0/4 -j RETURN
	iptables -t nat -A merlinclash -d "$lan_ipaddr" -j RETURN
	# redirect to Clash
	iptables -t nat -A merlinclash -p tcp -j REDIRECT --to-ports "$proxy_port"

	# process input traffic in merlinclash
	iptables -t nat -A PREROUTING -p tcp -j merlinclash

	#
	# udp traffic

	if [ "$merlinclash_udpr" == "1" ]; then
		echo_date "检测到开启udp转发，将创建相关iptable规则" >>$LOG_FILE

		# 加载 tproxy 内核模块
		load_tproxy

		ip rule add fwmark 1 table 100
		ip route add local default dev lo table 100

		iptables -t mangle -N merlinclash
		iptables -t mangle -F merlinclash
		# return local addr
		iptables -t mangle -A merlinclash -d 0.0.0.0/8 -j RETURN
		iptables -t mangle -A merlinclash -d 10.0.0.0/8 -j RETURN
		iptables -t mangle -A merlinclash -d 127.0.0.0/8 -j RETURN
		iptables -t mangle -A merlinclash -d 169.254.0.0/16 -j RETURN
		iptables -t mangle -A merlinclash -d 172.16.0.0/12 -j RETURN
		iptables -t mangle -A merlinclash -d 192.168.0.0/16 -j RETURN
		iptables -t mangle -A merlinclash -d 224.0.0.0/4 -j RETURN
		iptables -t mangle -A merlinclash -d 240.0.0.0/4 -j RETURN
		iptables -t mangle -A merlinclash -d "$lan_ipaddr" -j RETURN
		# redirect to Clash
		iptables -t mangle -A merlinclash -p udp -j TPROXY --on-port "$proxy_port" --tproxy-mark 1

		# process input traffic in merlinclash
		iptables -t mangle -A PREROUTING -p udp -j merlinclash
	else
		echo_date "【检测到udp转发未开启，进行下一步】" >>$LOG_FILE
	fi

	local dns_enable=$(yq r "$CONFIG_FILE" 'dns.enable')
	if [ "$dns_enable" == "true" ]; then
		# fake-ip
		if [ "$enhanced_mode" == "fake-ip" ]; then
			local fake_ip_range=$(yq r "$CONFIG_FILE" 'dns.fake-ip-range')

			# redirect tcp traffic to fake-ip to Clash
			iptables -t nat -A OUTPUT -p tcp -d "$fake_ip_range" -j REDIRECT --to-ports "$proxy_port"

			if [ "$merlinclash_udpr" == "1" ]; then
				# redirect udp traffic to fake-ip to Clash
				iptables -t mangle -A OUTPUT -p udp -d "$fake_ip_range" -j MARK --set-mark 1
			fi
		fi

		#
		# dns traffic

		local dns_port=$(yq r "$CONFIG_FILE" 'dns.listen' | awk -F: '{ print $2; }')

		if [ "$enhanced_mode" != "fake-ip" ] && [ "$merlinclash_dnsplan" == "rh" ]; then
			# redirect input traffic of dns to Clash dns
			iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports "$dns_port"
		else
			iptables -t nat -N clash_dns
			# delete all rules in clash_dns
			iptables -t nat -F clash_dns
			# exclude traffic of default nameserver
			local default_nameserver=$(yq r "$CONFIG_FILE" 'dns.default-nameserver')
			if [ -n "$default_nameserver" ]; then
				for nameserver in $default_nameserver; do
					iptables -t nat -A clash_dns -p udp -d "$nameserver" -j RETURN
				done
			fi
			# redirect to Clash dns
			iptables -t nat -A clash_dns -p udp -j REDIRECT --to-ports "$dns_port"
			# process output traffic of dns in clash_dns
			iptables -t nat -I OUTPUT -p udp --dport 53 -j clash_dns
			# redirect input traffic of dns to Clash dns
			iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports "$dns_port"
		fi
	fi

	#设备绕行
	lan_bypass

	# dashboard
	if [ "$merlinclash_dashboardswitch" == "1" ]; then
		iptables -I INPUT -p tcp --dport "$dashboard_port" -j ACCEPT
	else
		iptables -D INPUT -p tcp --dport "$dashboard_port" -j ACCEPT
	fi

	echo_date "iptable规则创建完成" >>$LOG_FILE
}

# 设备绕行20200721
lan_bypass() {
	# deivce_nu 获取已存数据序号
	echo_date "---------------------- 设备绕行检查区 开始 ------------------------" >>$LOG_FILE
	echo_date "【检查是否存在设备绕行】" >>$LOG_FILE
	device_nu=$(dbus list merlinclash_device_ip_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	num=0
	if [ -n "$device_nu" ]; then
		echo_date "【已设置设备绕行，将写入iptables】" >>$LOG_FILE
		#20200911新增链表 +++++++
		#iptables -t nat -N merlinclash_bypass
		#iptables -t mangle -N merlinclash_bypass

		#20200911新增链表 +++++++
		for device in $device_nu; do
			ip=$(eval "echo \$merlinclash_device_ip_$device")
			name=$(eval "echo \$merlinclash_device_name_$device")
			#20200920 新增模式处理
			mode=$(eval "echo \$merlinclash_device_mode_$device")
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
		echo_date "没有设置设备绕行" >>$LOG_FILE
	fi
	dbus remove merlinclash_device_ip
	dbus remove merlinclash_device_name
	dbus remove merlinclash_device_mode
	echo_date "---------------------- 设备绕行检查区 结束 ------------------------" >>$LOG_FILE
}

nat_ready() {
	local nat_rule=$(iptables -t nat -L PREROUTING | sed 1,2d)
	[ -n "$nat_rule" ]
	return
}

load_nat() {
	local i=120
	until nat_ready; do
		i=$((i - 1))
		if [ $i -lt 1 ]; then
			echo_date "错误：不能正确加载nat规则!" >>$LOG_FILE
			close_in_five
		fi
		sleep 1s
	done
	echo_date "加载nat规则!" >>$LOG_FILE
	sleep 1s
	apply_nat_rules3
	#chromecast
}

flush_nat() {
	local proxy_port=$(yq r "$CONFIG_FILE" 'redir-port')
	local dns_port=$(yq r "$CONFIG_FILE" 'dns.listen' | awk -F: '{ print $2; }')
	local fake_ip_range=$(yq r "$CONFIG_FILE" 'dns.fake-ip-range')

	echo_date "清除iptables规则..." >>$LOG_FILE

	# DNS
	iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports "$dns_port"
	iptables -t nat -D OUTPUT -p udp --dport 53 -j clash_dns
	iptables -t nat -F clash_dns
	iptables -t nat -X clash_dns

	# udp
	iptables -t mangle -D PREROUTING -p udp -i "$bridge" -j merlinclash
	if [ -n "$fake_ip_range" ]; then
		iptables -t mangle -D OUTPUT -p udp -d "$fake_ip_range" -j MARK --set-mark 1
	fi
	iptables -t mangle -F merlinclash
	iptables -t mangle -X merlinclash
	ip route del local default dev lo table 100
	ip rule del fwmark 1 table 100

	# tcp
	iptables -t nat -D PREROUTING -p tcp -j merlinclash
	if [ -n "$fake_ip_range" ]; then
		iptables -t nat -D OUTPUT -p tcp -d "$fake_ip_range" -j REDIRECT --to-ports "$proxy_port"
	fi
	iptables -t nat -F merlinclash
	iptables -t nat -X merlinclash

	# 清除外网访问端口
	iptables -D INPUT -p tcp --dport "$dashboard_port" -j ACCEPT

	#20200725清除设备绕行，测试++
	local ipt_1=$(echo "$lan_ipaddr" | awk -F"." '{print $1}')
	local ipt_2=$(echo "$lan_ipaddr" | awk -F"." '{print $2}')
	local ipt_3=$(echo "$lan_ipaddr" | awk -F"." '{print $3}')
	local ipt_4="$ipt_1.$ipt_2.$ipt_3"
	local nat_pass_indexs=$(iptables -nv -t nat -L PREROUTING --line-number | sed 1,2d | grep 'RETURN' | grep "$ipt_4" | awk '{print $1}' | sort -nr)
	for pass_index in $nat_pass_indexs; do
		iptables -t nat -D PREROUTING "$pass_index" &>/dev/null
	done
	local mangle_pass_indexs=$(iptables -nv -t mangle -L PREROUTING --line-number | sed 1,2d | grep 'RETURN' | grep "$ipt_4" | awk '{print $1}' | sort -nr)
	for pass_index in $mangle_pass_indexs; do
		iptables -t mangle -D PREROUTING "$pass_index" &>/dev/null
	done

	echo_date "清除iptables规则完毕..." >>$LOG_FILE
}

#######################
# clash
#######################

start_clash() {
	echo_date "启用 $CONFIG_NAME YAML配置" >>$LOG_FILE
	ln -sf "$CONFIG_FILE" /tmp/upload/view.txt
	/koolshare/bin/clash -d /koolshare/merlinclash/ -f "$CONFIG_FILE" &>/tmp/clash_run.log &
	#检查clash进程
	if [ "$merlinclash_check_delay_cbox" == "1" ]; then
		delaytime=$merlinclash_check_delay_time
		echo_date "延迟检查clash启动日志时间:$delaytime秒" >>$LOG_FILE
		sleep "$delaytime"
	else
		echo_date "延迟检查clash启动日志时间:2秒" >>$LOG_FILE
		sleep 2s
	fi
	if [ -n "$(pidof clash)" ] && (netstat -anp | grep -q clash) && [ ! $(grep -q "Parse config error" /tmp/clash_run.log) ]; then
		echo_date "Clash 进程启动成功！(PID: $(pidof clash))"
		rm -rf /tmp/upload/*.yaml
	else
		echo_date "Clash 进程启动失败！请检查配置文件是否存在问题，即将退出..."
		echo_date "失败原因："
		error1=$(grep -oE "Parse config error.*" /tmp/clash_run.log)
		error2=$(grep -oE "clashconfig.sh.*" /tmp/clash_run.log)
		error3=$(grep -oE "illegal instruction.*" /tmp/clash_run.log)
		if [ -n "$error1" ]; then
			echo_date "$error1" >>$LOG_FILE
		elif [ -n "$error2" ]; then
			echo_date "$error2" >>$LOG_FILE
		elif [ -n "$error3" ]; then
			echo_date "$error3" >>$LOG_FILE
		fi
		close_in_five
	fi
}

#######################
# config yaml
#######################

decode_url_link() {
	local url=$1
	local len=$(echo "$url" | wc -L)
	local mod4=$((len % 4))
	if [ $mod4 -gt 0 ]; then
		local placeholder="===="
		url="${url}${placeholder:$mod4}"
	fi
	echo -n "$url" | sed 's/-/+/g; s/_/\//g' | base64 -d 2>/dev/null
}

urldecode() {
	printf '%s\n' "$(echo -n "$1" | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g')"
}

check_config_yaml() {
	#通过获取的文件是否存在port: Rule: Proxy: Proxy Group: 标题头确认合法性
	local config_yaml=$1
	# 将 '\r' 转为 '\n'
	sh $KSSCRIPTS/clash_string.sh "$config_yaml"
	local port_lineno=$(grep -n "^port:" "$config_yaml" | awk -F ":" '{print $1}')
	if [ -z "$port_lineno" ]; then
		echo_date "配置文件缺少 'port:' 开头行，无法创建yaml文件" >>$LOG_FILE
		echo BBABBBBC >>$LOG_FILE
		exit 1
	else
		echo_date "出现 'port:' 的行数为: $port_lineno" >>$LOG_FILE
	fi
	local proxies_lineno=$(grep -n "^proxies:" "$config_yaml" | awk -F ":" '{print $1}')
	if [ -z "$proxies_lineno" ]; then
		echo_date "配置文件缺少 'proxies:' 开头行，无法创建yaml文件" >>$LOG_FILE
		echo BBABBBBC >>$LOG_FILE
		exit 1
	else
		echo_date "出现 'proxies:' 的行数为: $proxies_lineno" >>$LOG_FILE
	fi
	local port=$(sed -n '/^port:/p' "$config_yaml")
	local mixed_port=$(sed -n '/^mixed-port:/p' "$config_yaml")
	if [ -z "$port" ] && [ -z "$mixed_port" ]; then
		echo_date "clash配置文件不是合法的yaml文件，请检查订阅连接是否有误" >>$LOG_FILE
		rm -rf "$config_yaml"
		echo BBABBBBC >>$LOG_FILE
		exit 1
	fi
	echo_date "clash配置文件检查通过" >>$LOG_FILE
}

move_config() {
	# 查找upload文件夹是否有刚刚上传的yaml文件，正常只有一份
	echo_date "上传的文件名是: $merlinclash_uploadfilename" >>$LOG_FILE
	local upload_config=$UPLOAD_DIR/$merlinclash_uploadfilename
	if [ -f "$upload_config" ]; then
		echo_date "yaml文件合法性检查" >>$LOG_FILE
		check_yamlfile "$upload_config"

		echo_date "执行yaml文件处理工作"
		mkdir -p $UPLOAD_DIR/yaml
		rm -rf $UPLOAD_DIR/yaml/*
		cp -rf "$upload_config" $UPLOAD_DIR/yaml/$merlinclash_uploadfilename

		# 后台执行 上传文件名.yaml 处理工作，包括去注释，去空白行，去除 dns 以上头部，
		# 将标准头部文件复制一份到 /tmp/ 跟 tmp 的标准头部文件合并，生成新的 head.yaml，
		# 再将 head.yaml 复制到 /koolshare/merlinclash/ 并命名为 "上传文件名.yaml"
		sh $KSSCRIPTS/clash_yaml_upload_sub.sh
	else
		echo_date "没找到yaml文件"
		rm -rf $UPLOAD_DIR/*.yaml
		exit 1
	fi
}

watchdog() {
	if [ "$merlinclash_enable" == "1" ] && [ "$merlinclash_watchdog" == "1" ]; then
		sed -i '/clash_watchdog/d' /var/spool/cron/crontabs/* &>/dev/null
		watcdogtime=$merlinclash_watchdog_delay_time
		cru a clash_watchdog "*/$watcdogtime * * * * /bin/sh /koolshare/scripts/clash_watchdog.sh"
	#	/bin/sh /koolshare/scripts/clash_watchdog.sh &>/dev/null &
	else
		#pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
		#if [ -n "$pid_watchdog" ]; then
		echo_date 关闭看门狗... >>$LOG_FILE
		# 有时候killall杀不了v2ray进程，所以用不同方式杀两次
		#kill -9 "$pid_watchdog" &>/dev/null
		sed -i '/clash_watchdog/d' /var/spool/cron/crontabs/* &>/dev/null
		#fi
	fi
}

write_setmark_cron_job() {
	sed -i '/autosermark/d' /var/spool/cron/crontabs/* &>/dev/null
	sed -i '/autologdel/d' /var/spool/cron/crontabs/* &>/dev/null
	if [ "$merlinclash_enable" == "1" ]; then
		if [ -n "$(pidof clash)" ] && (netstat -anp | grep -q clash) && [ ! $(grep -q "Parse config error" /tmp/clash_run.log) ]; then
			echo_date "添加自动获取节点信息任务，每分钟自动检测节点选择状态." >>$LOG_FILE
			cru a autosermark "* * * * * /bin/sh /koolshare/scripts/clash_node_mark.sh setmark"
			#同时启动日志监测，1小时检测一次
			cru a autologdel "0 * * * * /bin/sh /koolshare/scripts/clash_logautodel.sh"
		#	/bin/sh /koolshare/scripts/clash_node_mark.sh setmark &>/dev/null &
		else
			echo_date "clash进程故障，不开启自动获取节点信息" >>$LOG_FILE
		fi
	fi
}

write_clash_restart_cron_job() {
	remove_clash_restart_regularly() {
		if [ -n "$(cru l | grep clash_restart)" ]; then
			sed -i '/clash_restart/d' /var/spool/cron/crontabs/* &>/dev/null
		fi
	}
	start_clash_restart_regularly_day() {
		remove_clash_restart_regularly
		cru a clash_restart "$merlinclash_select_clash_restart_minute $merlinclash_select_clash_restart_hour * * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
		echo_date "clash将于每日的${merlinclash_select_clash_restart_hour}时${merlinclash_select_clash_restart_minute}分重启" >>$LOG_FILE
	}
	start_clash_restart_regularly_week() {
		remove_clash_restart_regularly
		cru a clash_restart "$merlinclash_select_clash_restart_minute $merlinclash_select_clash_restart_hour * * $merlinclash_select_clash_restart_week /bin/sh /koolshare/scripts/clash_restart_update.sh"
		echo_date "clash将于每周${merlinclash_select_clash_restart_week}的${merlinclash_select_clash_restart_hour}时${merlinclash_select_clash_restart_minute}分重启" >>$LOG_FILE
	}
	start_clash_restart_regularly_month() {
		remove_clash_restart_regularly
		cru a clash_restart "$merlinclash_select_clash_restart_minute $merlinclash_select_clash_restart_hour $merlinclash_select_clash_restart_day * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
		echo_date "clash将于每月${merlinclash_select_clash_restart_day}号的${merlinclash_select_clash_restart_hour}时${merlinclash_select_clash_restart_minute}分重启" >>$LOG_FILE
	}

	start_clash_restart_regularly_mhour() {
		remove_clash_restart_regularly
		if [ "$merlinclash_select_clash_restart_minute_2" == "2" ] || [ "$merlinclash_select_clash_restart_minute_2" == "5" ] || [ "$merlinclash_select_clash_restart_minute_2" == "10" ] || [ "$merlinclash_select_clash_restart_minute_2" == "15" ] || [ "$merlinclash_select_clash_restart_minute_2" == "20" ] || [ "$merlinclash_select_clash_restart_minute_2" == "25" ] || [ "$merlinclash_select_clash_restart_minute_2" == "30" ]; then
			cru a clash_restart "*/${merlinclash_select_clash_restart_minute_2} * * * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
			echo_date "clash将每隔${merlinclash_select_clash_restart_minute_2}分钟重启" >>$LOG_FILE
		fi
		if [ "$merlinclash_select_clash_restart_minute_2" == "1" ] || [ "$merlinclash_select_clash_restart_minute_2" == "3" ] || [ "$merlinclash_select_clash_restart_minute_2" == "6" ] || [ "$merlinclash_select_clash_restart_minute_2" == "12" ]; then
			cru a clash_restart "0 */${merlinclash_select_clash_restart_minute_2} * * * /bin/sh /koolshare/scripts/clash_restart_update.sh"
			echo_date "clash将每隔${merlinclash_select_clash_restart_minute_2}小时重启" >>$LOG_FILE
		fi
	}
	case "$merlinclash_select_clash_restart" in
	1)
		echo_date "定时重启处于关闭状态" >>$LOG_FILE
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
		echo_date "定时重启处于关闭状态" >>$LOG_FILE
		remove_clash_restart_regularly
		;;
	esac
}

write_regular_cron_job() {
	remove_regular_subscribe() {
		if cru l | grep -q regular_subscribe; then
			sed -i '/regular_subscribe/d' /var/spool/cron/crontabs/* &>/dev/null
		fi
	}
	start_regular_subscribe_day() {
		remove_regular_subscribe
		cru a regular_subscribe "$merlinclash_select_regular_minute $merlinclash_select_regular_hour * * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
		echo_date "将于每日的${merlinclash_select_regular_hour}时${merlinclash_select_regular_minute}分重新订阅" >>$LOG_FILE
	}
	start_regular_subscribe_week() {
		remove_regular_subscribe
		cru a regular_subscribe "$merlinclash_select_regular_minute $merlinclash_select_regular_hour * * $merlinclash_select_regular_week /bin/sh /koolshare/scripts/clash_regular_update.sh"
		echo_date "将于每周${merlinclash_select_regular_week}的${merlinclash_select_regular_hour}时${merlinclash_select_regular_minute}分重新订阅" >>$LOG_FILE
	}
	start_regular_subscribe_month() {
		remove_regular_subscribe
		cru a regular_subscribe "$merlinclash_select_regular_minute $merlinclash_select_regular_hour $merlinclash_select_regular_day * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
		echo_date "将于每月${merlinclash_select_regular_day}号的${merlinclash_select_regular_hour}时${merlinclash_select_regular_minute}分重新订阅" >>$LOG_FILE
	}

	start_regular_subscribe_mhour() {
		remove_regular_subscribe
		if [ "$merlinclash_select_regular_minute_2" == "2" ] || [ "$merlinclash_select_regular_minute_2" == "5" ] || [ "$merlinclash_select_regular_minute_2" == "10" ] || [ "$merlinclash_select_regular_minute_2" == "15" ] || [ "$merlinclash_select_regular_minute_2" == "20" ] || [ "$merlinclash_select_regular_minute_2" == "25" ] || [ "$merlinclash_select_regular_minute_2" == "30" ]; then
			cru a regular_subscribe "*/$merlinclash_select_regular_minute_2 * * * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
			echo_date "将每隔${merlinclash_select_regular_minute_2}分钟重新订阅" >>$LOG_FILE
		fi
		if [ "$merlinclash_select_regular_minute_2" == "1" ] || [ "$merlinclash_select_regular_minute_2" == "3" ] || [ "$merlinclash_select_regular_minute_2" == "6" ] || [ "$merlinclash_select_regular_minute_2" == "12" ]; then
			cru a regular_subscribe "0 */${merlinclash_select_regular_minute_2} * * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
			echo_date "将每隔${merlinclash_select_regular_minute_2}小时重新订阅" >>$LOG_FILE
		fi
	}
	case "$merlinclash_select_regular_subscribe" in
	1)
		echo_date "定时订阅处于关闭状态" >>$LOG_FILE
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
		echo_date "定时订阅处于关闭状态" >>$LOG_FILE
		remove_regular_subscribe
		;;
	esac
}

detect() {
	echo_date "检测jffs2脚本是否开启"
	local MODEL=$(nvram get productid)
	# 检测jffs2脚本是否开启，如果没有开启，将会影响插件的自启和DNS部分（dnsmasq.postconf）
	#if [ "$MODEL" != "GT-AC5300" ];then
	# 判断为非官改固件的，即merlin固件，需要开启jffs2_scripts，官改固件不需要开启
	if [ ! $(nvram get extendno | grep -q koolshare) ]; then
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
	while [ $i -gt 0 ]; do
		sleep 1s
		echo_date $i
		i=$((i - 1))
	done
	dbus set merlinclash_enable="0"
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		sh /koolshare/scripts/clash_unblockneteasemusic.sh stop
	fi
	stop_config >/dev/null

	echo_date "插件已关闭！！"
	echo_date "======================= Merlin Clash ========================"
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
			type=$(eval "echo \$merlinclash_acl_type_$acl")
			#ipaddr_hex=$(echo $ipaddr | awk -F "." '{printf ("0x%02x", $1)} {printf ("%02x", $2)} {printf ("%02x", $3)} {printf ("%02x\n", $4)}')
			content=$(eval "echo \$merlinclash_acl_content_$acl")
			lianjie=$(eval "echo \$merlinclash_acl_lianjie_$acl")
			type=$(decode_url_link $type)
			content=$(decode_url_link $content)
			lianjie=$(decode_url_link $lianjie)
			type=$(urldecode $type)
			content=$(urldecode $content)
			lianjie=$(urldecode $lianjie)
			#写入自定规则到当前配置文件
			num1=$((num + 1))
			rules_line=$(sed -n -e '/^rules:/=' $CONFIG_FILE)
			echo_date "写入第$num1条自定规则到当前配置文件" >>$LOG_FILE

			sed "$rules_line a \ \ -\ $type,$content,$lianjie" -i $CONFIG_FILE
			let num++
		done
	else
		echo_date "没有自定规则" >>$LOG_FILE
	fi
	dbus remove merlinclash_acl_type
	dbus remove merlinclash_acl_content
	dbus remove merlinclash_acl_lianjie
	#格式化文本,避免rules:规则 - 未对齐而报错 -20200727
	sed -i '/^rules:/,/^port:/s/^[][ ]*- /  - /g' $CONFIG_FILE
	#格式化文本,避免proxies:节点 - 未对齐而报错 -20200727
	#aa=$(sed -n "/^proxies:/,/^proxy/p" $CONFIG_FILE | grep "\- name")
	#纯json格式，进行proxies:节点格式化
	#if [ -z "$aa" ]; then
	#	sed -i '/^proxies:/,/^proxy/s/^[][ ]*- /  - /g' $CONFIG_FILE
	#fi
}
#自定义容差值20200920
set_Tolerance() {
	if [ "$merlinclash_urltestTolerance_cbox" == "1" ]; then

		tolerance=$merlinclash_urltestTolerancesel
		echo_date "自定义延迟容差值:$tolerance" >>$LOG_FILE
		sed -i "s/tolerance: 100/tolerance: $tolerance/g" $CONFIG_FILE
	else
		echo_date "未定义延迟容差值，保持默认" >>$LOG_FILE

	fi
}

start_host() {
	host=$merlinclash_host_content1
	host_tmp=$merlinclash_host_content1_tmp
	# 新增中间值比较
	if [ "$host" != "$host_tmp" ]; then
		echo_date "检测到host区值变化" >>$LOG_FILE
		host=$(decode_url_link "$host")
		echo -e "$host" >$HOSTS_FILE
		# 删除空行
		sed -i '/^ *$/d' $HOSTS_FILE
		dbus set merlinclash_host_content1_tmp=$merlinclash_host_content1
	fi
	# 用 yq 处理 router.asus.com 的值，修改 router.asus.com ip地址为当前路由lanip
	router_tmp=$(yq r "$HOSTS_FILE" 'hosts.[router.asus.com]')
	echo_date "router.asus.com 值为: $router_tmp" >>$LOG_FILE
	if [ -n "$router_tmp" ] && [ "$router_tmp" != "$lan_ipaddr" ]; then
		echo_date "修正router.asus.com值为路由LANIP" >>$LOG_FILE
		yq w -i "$HOSTS_FILE" 'hosts.[router.asus.com]' "$lan_ipaddr"
	fi
	rm -rf $UPLOAD_DIR/host_yaml.txt
	ln -sf $HOSTS_FILE $UPLOAD_DIR/host_yaml.txt

	sed -i '$a' "$CONFIG_FILE"
	cat $HOSTS_FILE >>"$CONFIG_FILE"

	echo_date "             ++++++++++++++++++++++++++++++++++++++++" >>$LOG_FILE
	echo_date "             +              hosts处理完毕           +" >>$LOG_FILE
	echo_date "             ++++++++++++++++++++++++++++++++++++++++" >>$LOG_FILE
}

start_remark() {
	/bin/sh $KSSCRIPTS/clash_node_mark.sh remark
}

start_kcp() {
	# kcp_nu 获取已存数据序号

	kcp_nu=$(dbus list merlinclash_kcp_lport_ | cut -d "=" -f 1 | cut -d "_" -f 4 | sort -n)
	kcpnum=0
	if [ -n "$kcp_nu" ] && [ "$merlinclash_kcpswitch" == "1" ]; then
		echo_date "检查到KCP开启且有KCP配置，将启动KCP加速" >>$LOG_FILE
		for kcp in $kcp_nu; do
			lport=$(eval "echo \$merlinclash_kcp_lport_$kcp")
			server=$(eval "echo \$merlinclash_kcp_server_$kcp")
			port=$(eval "echo \$merlinclash_kcp_port_$kcp")
			param=$(eval "echo \$merlinclash_kcp_param_$kcp")
			#根据传入值启动kcp进程
			kcpnum1=$((kcpnum + 1))
			echo_date "启动第$kcpnum1个kcp进程" >>$LOG_FILE
			/koolshare/bin/client_linux_arm64 -l ":$lport" -r "$server:$port" "$param" &>/dev/null &
			local kcppid
			kcppid=$(pidof client_linux_arm64)
			if [ -n "$kcppid" ]; then
				echo_date "kcp进程启动成功，pid:$kcppid! "
			else
				echo_date "kcp进程启动失败！"
			fi
			kcpnum=$((kcpnum + 1))
		done
	else
		echo_date "没有打开KCP开关或者不存在KCP设置，不启动KCP加速" >>$LOG_FILE
		kcp_pid=$(pidof client_linux_arm64)
		if [ -n "$kcp_pid" ]; then
			echo_date "关闭残留KCP协议进程"... >>$LOG_FILE
			killall client_linux_arm64 &>/dev/null
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
	haveged_c -w 1024 &>/dev/null
}

creat_ipset() {
	echo_date 开始创建ipset名单
	ipset -! create merlinclash_white nethash && ipset flush merlinlclash_white
}

add_white_black_ip() {
	# black ip/cidr
	#ip_tg="149.154.0.0/16 91.108.4.0/22 91.108.56.0/24 109.239.140.0/24 67.198.55.0/24"
	#for ip in $ip_tg; do
	#    ipset -! add koolclash_black $ip &>/dev/null
	#done

	# white ip/cidr
	echo_date '应用局域网 IP 白名单'
	ip_lan="0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/4 $lan_ipaddr"
	for ip in $ip_lan; do
		ipset -! add merlinclash_white $ip &>/dev/null
	done

	#if [ ! -z $koolclash_firewall_whiteip_base64 ]; then
	#   ip_white=$(echo $koolclash_firewall_whiteip_base64 | base64_decode | sed '/\#/d')
	#    echo_date '应用外网目标 IP/CIDR 白名单'
	#    for ip in $ip_white; do
	#        ipset -! add koolclash_white $ip &>/dev/null
	#    done
	#fi
}

restart_dnsmasq() {
	# Restart dnsmasq
	echo_date "重启 dnsmasq..." >>$LOG_FILE
	service restart_dnsmasq &>/dev/null
}

check_yaml() {
	# 配合自定规则，此处修改为每次都从BAK恢复原版文件来操作
	# 每次从 /koolshare/merlinclash/yaml_bak 复制一份上传的 "上传文件名.yaml" 使用
	echo_date "从yaml_bak恢复初始文件" >>$LOG_FILE
	cp -rf "$BAK_DIR/$CONFIG_NAME.yaml" "$CONFIG_FILE"
	if [ -f "$CONFIG_FILE" ]; then
		echo_date "检查到Clash配置文件存在！选中的配置文件是【$CONFIG_NAME】" >>$LOG_FILE
	else
		echo_date "文件丢失，没有找到上传的配置文件！请先上传您的配置文件！" >>$LOG_FILE
		echo_date "...MerlinClash！退出中..." >>$LOG_FILE
		close_in_five
	fi
}

check_ss() {
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
start_dashboard() {
	#secret=$(cat $CONFIG_FILE | awk '/secret:/{print $2}' | sed 's/"//g')
	sed -i "s/^secret: \"clash\"/secret: \"$merlinclash_dashboard_secret\"/g" $CONFIG_FILE
	echo_date 修改管理面板密码为：$merlinclash_dashboard_secret
}

check_dnsplan() {
	echo_date "当前 dns 方案是: $merlinclash_dnsplan"

	# 插入换行符免得出错
	sed -i '$a' "$CONFIG_FILE"

	case $merlinclash_dnsplan in
	rh)
		# redir-host 方案: 将 /koolshare/merlinclash/上传文件名.yaml 跟 redirhost.yaml 合并
		echo_date "采用配置文件的默认 DNS 方案: Redir-Host" >>$LOG_FILE
		cat $DNS_DIR/redirhost.yaml >>"$CONFIG_FILE"
		;;
	rhp)
		# redir-host-plus 方案: 将 /koolshare/merlinclash/上传文件名.yaml 跟 rhplus.yaml 合并
		echo_date "采用 Redir-Host-Plus 的DNS方案" >>$LOG_FILE
		cat $DNS_DIR/rhplus.yaml >>"$CONFIG_FILE"
		;;
	fi)
		# fake-ip 方案: 将 /koolshare/merlinclash/上传文件名.yaml 跟 fakeip.yaml 合并
		echo_date "采用 Fake-ip的 DNS方案" >>$LOG_FILE
		cat $DNS_DIR/fakeip.yaml >>"$CONFIG_FILE"
		;;
	esac

	# 查找行数
	ipv6_lineno=$(grep -n "ipv6:" "$CONFIG_FILE" | awk -F ":" '{print $1}')
	# 删除行，再重写
	sed -i "$ipv6_lineno d" "$CONFIG_FILE"
	if [ "$merlinclash_enable" == "1" ] && [ "$merlinclash_ipv6switch" == "1" ]; then
		echo_date "检测到开启 ipv6，将为你设置 dns.ipv6 为 true" >>$LOG_FILE
		sed "$ipv6_lineno a \ \ ipv6: true" -i "$CONFIG_FILE"
	else
		echo_date "关闭clash或未开启ipv6，将为你设置dns.ipv6为false" >>$LOG_FILE
		sed "$ipv6_lineno a \ \ ipv6: false" -i "$CONFIG_FILE"
	fi
}

stop_config() {
	echo_date "触发脚本stop_config" >>$LOG_FILE
	#ss_pre_stop
	# now stop first
	echo_date "======================= MERLIN CLASH ========================" >>$LOG_FILE
	echo_date ""
	echo_date "--------------------------- 启动 ----------------------------" >>$LOG_FILE
	#stop_status
	echo_date "---------------------- 结束相关进程--------------------------" >>$LOG_FILE
	kill_cron_job
	if [ -f "$KSROOT/bin/UnblockNeteaseMusic" ]; then
		sh $KSSCRIPTS/clash_unblockneteasemusic.sh stop
	fi
	restart_dnsmasq
	kill_process
	echo_date "-------------------- 相关进程结束完毕 -----------------------" >>$LOG_FILE
	echo_date "----------------------清除iptables规则-----------------------" >>$LOG_FILE
	flush_nat
}

check_unblockneteasemusic() {
	if [ "$merlinclash_enable" == "1" ]; then
		if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
			echo_date "检测到开启网易云音乐本地解锁功能，开始处理" >>$LOG_FILE

			sh /koolshare/scripts/clash_unblockneteasemusic.sh restart
			sleep 1s
			#write_unblock
		else
			echo_date "网易云音乐本地解锁未开启" >>$LOG_FILE
			sh /koolshare/scripts/clash_unblockneteasemusic.sh stop
		fi
	fi
}

write_unblock() {
	ubm_process=$(pidof UnblockNeteaseMusic)
	if [ -n "$ubm_process" ]; then
		#获取proxies跟rules行号
		proxy_line=$(sed -n -e '/^proxies:/=' $CONFIG_FILE)
		rules_line=$(sed -n -e '/^rules:/=' $CONFIG_FILE)
		#ubm="\ \ - {name: 网易云解锁WINDOWS/ANDORID, server: music.desperadoj.com, port: 30001, type: ss, cipher: aes-128-gcm, password: desperadoj.com_free_proxy_x80j}"
		ubmlocal="\ \ - {name: 网易云解锁-本地, server: 127.0.0.1, port: 5200, type: http}"
		#ubm2="\ \ - {name: 网易云解锁MAC/IOS, server: music.desperadoj.com, port: 30003, type: ss, cipher: aes-128-gcm, password: desperadoj.com_free_proxy_x80j}"
		#写入proxies
		echo_date "写入网易云解锁的proxy跟proxy-group" >>$LOG_FILE
		#sed "$proxy_line a$ubm2" -i $CONFIG_FILE
		#sed "$proxy_line a$ubm" -i $CONFIG_FILE
		sed "$proxy_line a$ubmlocal" -i $CONFIG_FILE
		#写入proxy-groups

		1="\ \ - name: 🎵 Netease Music"
		pg2="\ \ \ \ type: select"
		pg3="\ \ \ \ proxies:"
		pg7="\ \ \ \ \ \ - 网易云解锁-本地"
		pg5="\ \ \ \ \ \ - DIRECT"
		sed "$rules_line a$pg1" -i $CONFIG_FILE

		let rules_line=$rules_line+1
		sed "$rules_line a$pg2" -i $CONFIG_FILE

		let rules_line=$rules_line+1
		sed "$rules_line a$pg3" -i $CONFIG_FILE

		let rules_line=$rules_line+1
		sed "$rules_line a$pg7" -i $CONFIG_FILE

		let rules_line=$rules_line+1
		sed "$rules_line a$pg5" -i $CONFIG_FILE

		#写入网易云的clash rule部分  格式:  - "DOMAIN-SUFFIX,acl4ssr,\U0001F3AF 全球直连"
		echo_date 写入网易云的clash rule部分 >>$LOG_FILE
		rules_line=$(sed -n -e '/^rules:/=' $CONFIG_FILE)

		sed "$rules_line a \ \ -\ IP-CIDR,223.252.199.67/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,223.252.199.66/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,193.112.159.225/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,118.24.63.156/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,115.236.121.3/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,115.236.121.1/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,115.236.118.33/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,112.13.122.1/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,112.13.119.17/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,103.126.92.133/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,103.126.92.132/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,101.71.154.241/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.238.29/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.181.35/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.160.197/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.160.195/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.181.60/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.181.38/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.179.214/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,59.111.21.14/31,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,47.100.127.239/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,45.254.48.1/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,42.186.120.199/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ IP-CIDR,39.105.63.80/32,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,nstool.netease.com,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,hz.netease.com,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,mam.netease.com,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,interface3.music.163.com,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,interface.music.163.com,🎵 Netease Music" -i $CONFIG_FILE

		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,apm.music.163.com,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,apm3.music.163.com,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,api.iplay.163.com,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,music.163.com,🎵 Netease Music" -i $CONFIG_FILE
		sed "$rules_line a \ \ -\ DOMAIN-SUFFIX,163yun.com,🎵 Netease Music" -i $CONFIG_FILE
	else
		echo_date "网易云音乐解锁无法启动" >>$LOG_FILE
		dbus set $merlinclash_unblockmusic_enable="0"
	fi
}

auto_start() {
	echo_date "创建开机/iptable重启任务" >>$LOG_FILE
	[ ! -L "/koolshare/init.d/S99merlinclash.sh" ] && ln -sf /koolshare/merlinclash/clashconfig.sh /koolshare/init.d/S99merlinclash.sh
	[ ! -L "/koolshare/init.d/N99merlinclash.sh" ] && ln -sf /koolshare/merlinclash/clashconfig.sh /koolshare/init.d/N99merlinclash.sh
}

#######################
# start/kill
#######################

kill_clash() {
	clash_pid=$(pidof clash)
	if [ -n "$clash_pid" ]; then
		echo_date 关闭clash进程...
		# 有时候killall杀不了clash进程，所以用不同方式杀两次
		killall clash &>/dev/null
		kill -9 "$clash_pid" &>/dev/null
	fi
}

kill_setmark() {
	setmark_pid=$(ps | grep clash_node_mark.sh | grep -v grep | awk '{print $1}')
	if [ -n "$setmark_pid" ]; then
		echo_date "关闭节点状态获取进程..."
		# 有时候killall杀不了v2ray进程，所以用不同方式杀两次
		kill -9 "$setmark_pid" &>/dev/null
	fi
}

kill_process() {
	kcp_pid=$(pidof client_linux_arm64)
	if [ -n "$kcp_pid" ]; then
		echo_date "关闭kcp协议进程..." >>$LOG_FILE
		killall client_linux_arm64 &>/dev/null
	fi

	kill_clash

	haveged_pid=$(pidof haveged_c)
	if [ -n "$haveged_pid" ]; then
		echo_date "关闭haveged进程." >>$LOG_FILE
		killall haveged_c &>/dev/null
	fi

	#pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
	#if [ -n "$pid_watchdog" ]; then
	#	echo_date 关闭看门狗进程...
	#   # 有时候killall杀不了watchdog进程，所以用不同方式杀两次
	#	kill -9 "$pid_watchdog" &>/dev/null
	#fi

	#kill_setmark
}

kill_cron_job() {
	if cru l | grep -q autosermark; then
		echo_date "删除自动获取节点信息任务..." >>$LOG_FILE
		sed -i '/autosermark/d' /var/spool/cron/crontabs/* &>/dev/null
	fi
	if cru l | grep -q autologdel; then
		echo_date "删除日志监测任务..." >>$LOG_FILE
		sed -i '/autologdel/d' /var/spool/cron/crontabs/* &>/dev/null
	fi
	if cru l | grep -q clash_watchdog; then
		echo_date "删除看门狗任务..." >>$LOG_FILE
		sed -i '/clash_watchdog/d' /var/spool/cron/crontabs/* &>/dev/null
	fi
	if cru l | grep -q regular_subscribe; then
		echo_date "删除定时订阅任务..." >>$LOG_FILE
		sed -i '/regular_subscribe/d' /var/spool/cron/crontabs/* &>/dev/null
	fi
	if cru l | grep -q clash_restart; then
		echo_date "删除定时重启任务..." >>$LOG_FILE
		sed -i '/clash_restart/d' /var/spool/cron/crontabs/* &>/dev/null
	fi
}

#######################
# main
#######################

apply_mc() {
	# router is on boot
	WAN_ACTION=$(ps | grep /jffs/scripts/wan-start | grep -v grep)

	# now stop first
	echo_date "======================= MERLIN CLASH =======================" >>$LOG_FILE
	echo_date "-------------------- 检查是否存冲突插件 --------------------" >>$LOG_FILE
	check_ss
	echo_date "----------------------- 重启dnsmasq ------------------------" >>$LOG_FILE
	restart_dnsmasq
	echo_date "----------------------- 结束相关进程 -----------------------" >>$LOG_FILE
	kill_process
	echo_date "--------------------- 相关进程结束完毕 ---------------------" >>$LOG_FILE
	kill_cron_job
	echo_date "------------------- 检查配置文件是否存在 -------------------" >>$LOG_FILE
	check_yaml
	echo_date ""
	echo_date "--------------------- 添加host区 开始 ----------------------" >>$LOG_FILE
	start_host
	echo_date "--------------------- 添加host区 结束 ----------------------" >>$LOG_FILE
	echo_date ""
	echo_date "----------------------- 确认DNS方案 ------------------------" >>$LOG_FILE
	check_dnsplan
	echo_date "------------------ 自定义规则检查区 开始 -------------------" >>$LOG_FILE
	check_rule
	echo_date "------------------ 自定义规则检查区 结束 -------------------" >>$LOG_FILE
	echo_date ""
	echo_date "------------------ 自定义延迟容差值 开始 -------------------" >>$LOG_FILE
	set_Tolerance
	echo_date "------------------- 自定义延迟容差 结束 --------------------" >>$LOG_FILE
	echo_date ""
	# 清除iptables规则和ipset...
	echo_date "------------------ 清除iptables规则 开始 -------------------" >>$LOG_FILE
	flush_nat
	echo_date "------------------ 清除iptables规则 结束 -------------------" >>$LOG_FILE
	echo_date ""
	echo_date "--------------------- 面板定义区 开始 ----------------------" >>$LOG_FILE
	start_dashboard
	echo_date "--------------------- 面板定义区 结束 ----------------------" >>$LOG_FILE
	echo_date ""
	echo_date "------------------ 网易云功能检查区 开始 -------------------" >>$LOG_FILE
	check_unblockneteasemusic
	echo_date "------------------ 网易云功能检查区 结束 -------------------" >>$LOG_FILE
	# 检测jffs2脚本是否开启
	detect
	# 启动haveged，为系统提供更多的可用熵！
	set_sys
	echo_date "--------------------- 启动插件相关功能 ---------------------" >>$LOG_FILE
	start_clash && echo_date "start_clash" >>$LOG_FILE
	#echo_date "-------------------- 节点记忆检查区 开始--------------------" >> $LOG_FILE
	#start_host
	#echo_date "-------------------- 节点记忆检查区 结束--------------------" >> $LOG_FILE
	echo_date "-------------------- 恢复记忆节点 开始 ---------------------" >>$LOG_FILE
	start_remark
	echo_date "-------------------- 恢复记忆节点 结束 ---------------------" >>$LOG_FILE
	echo_date ""
	echo_date "------------------ 创建iptables规则 开始 -------------------" >>$LOG_FILE
	load_nat
	echo_date "------------------ 创建iptables规则 结束 -------------------" >>$LOG_FILE
	echo_date ""
	#----------------------------------KCP进程--------------------------------
	echo_date "-------------------- KCP设置检查区 开始 --------------------" >>$LOG_FILE
	start_kcp
	echo_date "-------------------- KCP设置检查区 结束 --------------------" >>$LOG_FILE
	#----------------------------------应用节点记忆----------------------------
	restart_dnsmasq
	auto_start
	watchdog
	echo_date "------------------- 节点后台记忆区 开始 --------------------" >>$LOG_FILE
	write_setmark_cron_job
	echo_date "------------------- 节点后台记忆区 结束 --------------------" >>$LOG_FILE
	echo_date ""
	echo_date "------------------- 定时订阅检查区 开始 --------------------" >>$LOG_FILE
	write_regular_cron_job
	echo_date "------------------- 定时订阅检查区 结束 --------------------" >>$LOG_FILE
	echo_date ""
	echo_date "------------------- 定时重启检查区 开始 --------------------" >>$LOG_FILE
	write_clash_restart_cron_job
	echo_date "------------------- 定时重启检查区 结束 --------------------" >>$LOG_FILE
	echo_date "          +      管理面板： $lan_ipaddr:9990     +" >>$LOG_FILE
	echo_date "          +      Http代理： $lan_ipaddr:7890     +" >>$LOG_FILE
	echo_date "          +      Socks代理：$lan_ipaddr:7891     +" >>$LOG_FILE
	echo_date "          ++++++++++++++++++++++++++++++++++++++++" >>$LOG_FILE
	echo_date ""
	echo_date "                 恭喜！开启MerlinClash成功！" >>$LOG_FILE
	echo_date ""
	echo_date "如果不能科学上网，请刷新设备dns缓存，或者等待几分钟再尝试" >>$LOG_FILE
	echo_date ""
	echo_date "================ 【MERLIN CLASH】 启动完毕 =================" >>$LOG_FILE
}

restart_mc_quickly() {
	echo_date "----------------------- 结束相关进程 -----------------------" >>$LOG_FILE
	kill_clash
	#kill_cron_job
	echo_date "--------------------- 启动插件相关功能 ---------------------" >>$LOG_FILE
	start_clash && echo_date "start_clash" >>$LOG_FILE
	echo_date "-------------------- 恢复记忆节点 开始 ---------------------" >>$LOG_FILE
	start_remark
	echo_date "-------------------- 恢复记忆节点 结束 ---------------------" >>$LOG_FILE
	restart_dnsmasq
	#===load nat end===
	# 创建开机/IPT重启任务！
	auto_start
	#kill_setmark
	#watchdog
	echo_date "------------------- 节点后台记忆区 开始 --------------------" >>$LOG_FILE
	#write_setmark_cron_job
	echo_date "------------------- 节点后台记忆区 开始 --------------------" >>$LOG_FILE
	#echo_date "" >>$LOG_FILE
	#echo_date "------------------- 定时订阅检查区 开始 --------------------" >>$LOG_FILE
	#write_regular_cron_job
	#echo_date "------------------- 定时订阅检查区 结束 --------------------" >>$LOG_FILE
	echo_date "" >>$LOG_FILE
	echo_date "          ++++++++++++++++++++++++++++++++++++++++" >>$LOG_FILE
	echo_date "          +      管理面板： $lan_ipaddr:9990     +" >>$LOG_FILE
	echo_date "          +      Http代理： $lan_ipaddr:7890     +" >>$LOG_FILE
	echo_date "          +      Socks代理：$lan_ipaddr:7891     +" >>$LOG_FILE
	echo_date "          ++++++++++++++++++++++++++++++++++++++++" >>$LOG_FILE
	echo_date ""
	echo_date "                 恭喜！开启MerlinClash成功！" >>$LOG_FILE
	echo_date ""
	echo_date "如果不能科学上网，请刷新设备dns缓存，或者等待几分钟再尝试" >>$LOG_FILE
	echo_date ""
	echo_date "================ 【MERLIN CLASH】 启动完毕 =================" >>$LOG_FILE
}

case $ACTION in
start)
	mkdir -p /tmp/lock

	echo_log "[软件中心]: 开机启动MerlinClash插件！"

	#set_lock
	if [ "$merlinclash_enable" == "1" ]; then

		dbus get merlinclash_lockfile
		last_lcfile=/tmp/lock/$merlinclash_lockfile.txt
		echo_date "前一进程锁文件:$last_lcfile" >>$LOG_FILE

		lcname=$$
		merlinclash_lockfile="$lcname"
		dbus set merlinclash_lockfile="$merlinclash_lockfile"
		lcfile=/tmp/lock/$lcname.txt
		echo_date "触发重启任务pid: $$" >>$LOG_FILE

		echo_date "创建本重启进程锁文件: ${lcfile}" >>$LOG_FILE
		touch $lcfile

		echo_date "将本任务pid写入lockfile: $merlinclash_lockfile" >>$LOG_FILE
		echo $$ >${lcfile}

		i=60
		while [ $i -ge 0 ]; do
			if [ -e "$last_lcfile" ] && kill -0 "$(cat $lcfiletmp)"; then
				echo_date " $merlinclash_lockfile 锁进程中" >>$LOG_FILE
				echo $$ >${lcfile}
				sleep 5s
			else
				i=0
				echo_date "上个重启进程文件锁解除" >>$LOG_FILE
			fi
			i=$((i - 1))
		done

		# 确保退出时，锁文件被删除
		trap "rm -rf $lcfile; exit" INT TERM EXIT

		echo $$ >${lcfile}
		echo_date "2次创建本重启进程锁文件: ${lcfile}" >>$LOG_FILE

		apply_mc >>"$LOG_FILE"
	else
		echo_log "[软件中心]: MerlinClash插件未开启，不启动！"
	fi
	rm -rf $lcfile
	#unset_lock
	;;
upload)
	move_config >>"$LOG_FILE"
	http_response 'success'
	;;
stop)
	set_lock
	stop_config
	echo_date >>$LOG_FILE
	echo_date 你已经成功关闭Merlin Clash~ >>$LOG_FILE
	echo_date See you again! >>$LOG_FILE
	echo_date >>$LOG_FILE
	echo_date ======================= Merlin Clash ======================== >>$LOG_FILE
	unset_lock
	;;
restart)
	set_lock
	apply_mc
	echo_date >>$LOG_FILE
	echo_date "Across the Great Wall we can reach every corner in the world!" >>$LOG_FILE
	echo_date >>$LOG_FILE
	echo_date ======================= Merlin Clash ======================== >>$LOG_FILE
	unset_lock
	;;
quicklyrestart)
	set_lock
	restart_mc_quickly
	echo_date >>$LOG_FILE
	echo_date "Across the Great Wall we can reach every corner in the world!" >>$LOG_FILE
	echo_date >>$LOG_FILE
	echo_date ======================= Merlin Clash ======================== >>$LOG_FILE
	unset_lock
	;;
start_nat)
	#set_lock
	mkdir -p /tmp/lock

	echo_date "================= Merlin Clash Start Nat Begin =================" >>$LOG_FILE
	dbus get merlinclash_lockfile
	lcfiletmp=/tmp/lock/$merlinclash_lockfile.txt
	echo_date "前一进程锁文件:$lcfiletmp" >>$LOG_FILE

	lc=$$
	merlinclash_lockfile="$lc"
	dbus set merlinclash_lockfile="$merlinclash_lockfile"
	lcfile1=/tmp/lock/$lc.txt
	echo_date "触发重启任务pid:$lc" >>$LOG_FILE

	echo_date "创建本重启进程锁文件${lcfile1}" >>$LOG_FILE
	touch $lcfile1

	i=60

	echo_date "将本任务pid写入lockfile:$merlinclash_lockfile" >>$LOG_FILE
	echo $$ >${lcfile1}
	#sleep 1s

	while [ $i -ge 0 ]; do
		if [ -e ${lcfiletmp} ] && kill -0 "$(cat $lcfiletmp)"; then
			echo_date " $merlinclash_lockfile 锁进程中" >>$LOG_FILE
			#echo $$ > {$merlinclash_lockfile}_{$lc}.txt
			#echo_date "将当前进程id写入锁文件${lcfile1}" >> $LOG_FILE
			#echo $$ > ${lcfile1}
			sleep 5s
		else
			i=0
			echo_date "上个重启进程文件锁解除" >>$LOG_FILE
		fi
		i=$((i - 1))
	done

	# 确保退出时，锁文件被删除
	trap "rm -rf $lcfile1; exit" INT TERM EXIT

	echo $$ >${lcfile1}
	echo_date "2次创建本重启进程锁文件${lcfile1}" >>$LOG_FILE
	logger "[软件中心]: iptable发生变化，Merlin Clash nat重启！"
	echo_date "============= Merlin Clash iptable 重写开始=============" >>$LOG_FILE
	echo_date "[软件中心]: iptable发生变化，Merlin Clash nat重启！" >>$LOG_FILE
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
		echo_date "============= Merlin Clash iptable 重写完成=============" >>$LOG_FILE
	else
		logger "[软件中心]: MerlinClash插件未开启，不启动！"
		echo_date "[软件中心]: MerlinClash插件未开启，不启动！" >>$LOG_FILE
	fi
	#unset_lock
	# 删除锁文件
	rm -rf ${lcfile1}
	echo_date "================= Merlin Clash Start Nat END =================" >>$LOG_FILE
	;;
esac
