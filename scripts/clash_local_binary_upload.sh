#!/bin/sh
 
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
upload_path=/tmp/upload
upload_file=/tmp/upload/clash

yamlname=$merlinclash_yamlsel
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml

local_binary_replace(){
	chmod +x $upload_file
	clash_upload_ver=$($upload_file -v 2>/dev/null | head -n 1 | cut -d " " -f2)
	if [ -n "$clash_upload_ver" ]; then
		echo_date "上传clash二进制版本为：$clash_upload_ver" >> $LOG_FILE
		echo_date "开始替换处理" >> $LOG_FILE
		replace_binary
	else
		echo_date "上传的二进制不合法！！！" >> $LOG_FILE
	fi
	
}

replace_binary(){
	echo_date "检查空间" >> $LOG_FILE
	SPACE_AVAL=$(df|grep jffs | awk '{print $4}')
	SPACE_NEED=$(du -s /tmp/upload/clash | awk '{print $1}')
	if [ "$SPACE_AVAL" -gt "$SPACE_NEED" ];then
		echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 二进制需要"$SPACE_NEED" KB，空间满足，继续安装！ >> $LOG_FILE
		echo_date "开始替换clash二进制!" >> $LOG_FILE
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
		rm -rf /tmp/upload/clash
		exit 1
	fi
}

move_binary(){
	echo_date "开始替换clash二进制文件... " >> $LOG_FILE
	mv $upload_file /koolshare/bin/clash
	chmod +x /koolshare/bin/clash
	clash_LOCAL_VER=$(/koolshare/bin/clash -v 2>/dev/null | head -n 1 | cut -d " " -f2)
	[ -n "$clash_LOCAL_VER" ] && dbus set merlinclash_clash_version="$clash_LOCAL_VER"
	echo_date "clash二进制文件替换成功... " >> $LOG_FILE
}

start_clash(){
	echo_date "开启clash进程... " >> $LOG_FILE

	/bin/sh /koolshare/merlinclash/clashconfig.sh quicklyrestart
	
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
12)
	echo "本地上传clash二进制替换" > $LOG_FILE
	http_response "$1"
	local_binary_replace >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE	
	;;
esac