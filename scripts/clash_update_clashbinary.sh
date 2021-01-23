#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
url_main="https://raw.githubusercontent.com/flyhigherpi/merlinclash_clash_related/master"
url_back=""
yamlname=$merlinclash_yamlsel
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml

get_latest_version(){
	rm -rf /tmp/upload/clash_latest_info.txt
	echo_date "检测clash最新版本..." >> $LOG_FILE
	#插入hosts,免得raw.githubusercontent.com解析失败
	#if grep -q "raw.githubusercontent.com" /etc/hosts; then
	#	echo_date "已存在raw.githubusercontent.com的host记录" >> $LOG_FILE
	#else
	#	echo_date "创建raw.githubusercontent.com的host记录" >> $LOG_FILE
	#	sed -i '$a\151.101.128.133 raw.githubusercontent.com' /etc/hosts
	#fi
	curl --connect-timeout 8 -s $url_main/clash_binary_version.txt > /tmp/upload/clash_latest_info.txt
	if [ "$?" == "0" ];then
		if [ -z "`cat /tmp/upload/clash_latest_info.txt`" ];then 
			echo_date "获取clash最新版本信息失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "`cat /tmp/upload/clash_latest_info.txt|grep "404"`" ];then
			echo_date "error:404 | 获取clash最新版本信息失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "$(cat /tmp/upload/clash_latest_info.txt|grep "500")" ];then
			echo_date "error:500 | 获取clash版本文件失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		ClashVERSION=`cat /tmp/upload/clash_latest_info.txt | sed 's/v//g'` || 0
		ClashVERSION_TMP=$(echo $ClashVERSION | awk -F"-" '{print $1}')
		echo_date "检测到clash最新版本：v$ClashVERSION" >> $LOG_FILE
		if [ ! -f "/koolshare/bin/clash" ];then
			echo_date "Clash安装文件丢失！重新下载！" >> $LOG_FILE
			CUR_VER="0"
		else
			CUR_VER=`clash -v 2>/dev/null | head -n 1 | cut -d " " -f2 | sed 's/v//g'` || 0
			CUR_VER_TMP=$(echo $CUR_VER | awk -F"-" '{print $1}')
			echo_date "当前已安装clash版本：v$CUR_VER" >> $LOG_FILE
		fi
		COMP=$(versioncmp $CUR_VER_TMP $ClashVERSION_TMP)
		if [ "$COMP" == "1" ];then
			[ "$CUR_VER" != "0" ] && echo_date "clash已安装版本号低于最新版本，开始更新程序..." >> $LOG_FILE
			update_now v$ClashVERSION
		else
			clash_LOCAL_VER=`/koolshare/bin/clash -v 2>/dev/null | head -n 1 | cut -d " " -f2`
			
			[ -n "$clash_LOCAL_VER" ] && dbus set merlinclash_clash_version="$clash_LOCAL_VER"
			
			echo_date "clash已安装版本已经是最新，退出更新程序!" >> $LOG_FILE
		fi
	else
		echo_date "获取clash最新版本信息失败！" >> $LOG_FILE
		failed_warning_clash
	fi
}

failed_warning_clash(){
	echo_date "获取文件失败！！请检查网络！注意raw.githubusercontent.com的DNS解析结果" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC
	exit 1
}

update_now(){
	rm -rf /tmp/clash
	mkdir -p /tmp/clash && cd /tmp/clash

	echo_date "开始下载校验文件：md5sum.txt" >> $LOG_FILE
	wget --no-check-certificate --timeout=20 -qO - $url_main/$1/md5sum.txt > /tmp/clash/md5sum.txt
	if [ "$?" != "0" ];then
		echo_date "md5sum.txt下载失败！" >> $LOG_FILE
		md5sum_ok=0
	else
		md5sum_ok=1
		echo_date "md5sum.txt下载成功..." >> $LOG_FILE
	fi
	
	echo_date "开始下载clash程序" >> $LOG_FILE
	wget --no-check-certificate --timeout=20 --tries=1 $url_main/$1/clash
	#curl -L -H "Cache-Control: no-cache" -o /tmp/clash/v2ray $url_main/$1/v2ray
	if [ "$?" != "0" ];then
		echo_date "clash下载失败！" >> $LOG_FILE
		clash_ok=0
	else
		clash_ok=1
		echo_date "clash程序下载成功..." >> $LOG_FILE
	fi	

	if [ "$md5sum_ok" == "1" ] && [ "$clash_ok" == "1" ]; then
		check_md5sum
	else
		echo_date "使用备用服务器下载..." >> $LOG_FILE
		echo_date "下载失败，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}

check_md5sum(){
	cd /tmp/clash
	echo_date "校验下载的文件!" >> $LOG_FILE
	clash_LOCAL_MD5=$(md5sum clash|awk '{print $1}')
	clash_ONLINE_MD5=$(cat md5sum.txt|awk '{print $1}')
	if [ "$clash_LOCAL_MD5"x = "$clash_ONLINE_MD5"x ]; then
		echo_date "文件校验通过!" >> $LOG_FILE
		install_binary
	else
		echo_date "校验未通过，可能是下载过程出现了什么问题，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}

install_binary(){
	echo_date "检查空间" >> $LOG_FILE
	SPACE_AVAL=$(df|grep jffs | awk '{print $4}')
	SPACE_NEED=$(du -s /tmp/clash/clash | awk '{print $1}')
	if [ "$SPACE_AVAL" -gt "$SPACE_NEED" ];then
		echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 二进制需要"$SPACE_NEED" KB，空间满足，继续安装！ >> $LOG_FILE
		echo_date "开始覆盖最新二进制!" >> $LOG_FILE
		if [ "$(pidof clash)" ];then
			echo_date "为了保证更新正确，先关闭clash主进程... " >> $LOG_FILE
			killall clash >/dev/null 2>&1
			move_binary
			sleep 1
			start_clash
		else
			move_binary
		fi
	else
		echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 二进制需要"$SPACE_NEED" KB，空间不足！ >> $LOG_FILE
		echo_date 退出安装！ >> $LOG_FILE
		cd
		rm -rf /tmp/clash
		exit 1
	fi
}

move_binary(){
	echo_date "开始替换clash二进制文件... " >> $LOG_FILE
	mv /tmp/clash/clash /koolshare/bin/clash
	chmod +x /koolshare/bin/clash
	clash_LOCAL_VER=`/koolshare/bin/clash -v 2>/dev/null | head -n 1 | cut -d " " -f2`
	[ -n "$clash_LOCAL_VER" ] && dbus set merlinclash_clash_version="$clash_LOCAL_VER"
	echo_date "clash二进制文件替换成功... " >> $LOG_FILE
}

start_clash(){
	echo_date "开启clash进程... " >> $LOG_FILE
	/bin/sh /koolshare/merlinclash/clashconfig.sh restart
}

close_in_five() {
	echo_date "插件将在5秒后自动关闭！！"
	local i=5
	while [ $i -ge 0 ]; do
		sleep 1
		echo_date $i
		let i--
	done
	dbus set merlinclash_enable="0"
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		sh /koolshare/scripts/clash_unblockneteasemusic.sh stop
	fi
	sh /koolshare/merlinclash/clashconfig.sh stop
}


case $2 in
7)
	echo " " > $LOG_FILE
	http_response "$1"
	echo_date "===================================================================" >> $LOG_FILE
	echo_date "                clash程序更新(基于sadog v2ray程序更新修改)" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	get_latest_version >> $LOG_FILE 2>&1
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	;;
esac