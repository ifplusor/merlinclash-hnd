#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt

#CDN地址示例
#https://cdn.jsdelivr.net/gh/flyhigherpi/merlinclash_clash_related/clash_binary_history/clashP-armv8-2020.08.16/md5sum.txt         
url_back=""
yamlname=$merlinclash_yamlsel
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml
flag=$merlinclash_flag
UA='Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36';
if [ "$flag" == "HND" ]; then
	url_main="https://raw.githubusercontent.com/flyhigherpi/merlinclash_clash_related/master/clash_binary_history" 
else
	url_main="https://raw.githubusercontent.com/flyhigherpi/merlinclash_clash_related/master/384_clash_binary_history"
fi
get_binary_history(){
    rm -rf /koolshare/merlinclash/clash_binary_history.txt
	rm -rf /tmp/upload/clash_binary_history.txt
	#插入hosts,免得raw.githubusercontent.com解析失败
	#if grep -q "raw.githubusercontent.com" /etc/hosts; then
	#	echo_date "已存在raw.githubusercontent.com的host记录" >> $LOG_FILE
	#else
	#	echo_date "创建raw.githubusercontent.com的host记录" >> $LOG_FILE
	#	sed -i '$a\151.101.64.133 raw.githubusercontent.com' /etc/hosts
	#fi
	
    echo_date "下载clash历史版本号文件..." >> $LOG_FILE	
    curl --connect-timeout 60 -s ${url_main}/clash_binary_history.txt > /tmp/upload/clash_binary_history.txt
	if [ "$?" == "0" ];then
		echo_date "检查文件完整性" >> $LOG_FILE
       		if [ -z "$(cat /tmp/upload/clash_binary_history.txt)" ];then 
			echo_date "获取clash版本文件失败！" >> $LOG_FILE
			failed_warning_clash
		fi
        #if [ -n "$(cat /tmp/upload/clash_binary_history.txt|grep "404")" ];then
		#	echo_date "error:404 | 获取clash版本文件失败！" >> $LOG_FILE
		#	failed_warning_clash
		#fi
		if [ -n "$(cat /tmp/upload/clash_binary_history.txt|grep "clash")" ];then
			echo_date "已获取服务器端clash版本号文件" >> $LOG_FILE
			mv -f /tmp/upload/clash_binary_history.txt /koolshare/merlinclash/clash_binary_history.txt        
		else
			echo_date "获取clash版本文件失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		
	else
		echo_date "获取clash版本文件失败！" >> $LOG_FILE
		failed_warning_clash
	fi
    
}

failed_warning_clash(){
	rm -rf /koolshare/merlinclash/clash_binary_history.txt
	rm -rf /tmp/upload/clash_binary_history.txt
	echo_date "获取文件失败！！请检查网络！注意raw.githubusercontent.com的DNS解析结果" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC
	exit 1
}

replace_clash_binary(){
	echo_date "选中clash二进制版本为：$merlinclash_clashbinarysel" >> $LOG_FILE
	echo_date "开始替换处理" >> $LOG_FILE
	binarysel=$merlinclash_clashbinarysel

	rm -rf /tmp/clash_binary
	mkdir -p /tmp/clash_binary && cd /tmp/clash_binary
	echo_date "从服务器1下载校验文件：md5sum.txt" >> $LOG_FILE
	wget --user-agent="$UA" --no-check-certificate --timeout=20 -qO - ${url_main}/$binarysel/md5sum.txt > /tmp/clash_binary/md5sum.txt

	if [ "$?" != "0" ];then
		echo_date "md5sum.txt下载失败！" >> $LOG_FILE
		md5sum_ok=0
	else
		md5sum_ok=1
		echo_date "md5sum.txt下载成功..." >> $LOG_FILE
	fi
	#20200818从cdn地址下载md5sum进行比对，决定二进制下载路径
	if [ "$flag" == "HND" ]; then
		url_cdn="https://cdn.jsdelivr.net/gh/flyhigherpi/merlinclash_clash_related/clash_binary_history"
	else
		url_cdn="https://cdn.jsdelivr.net/gh/flyhigherpi/merlinclash_clash_related/384_clash_binary_history"
	fi
	echo_date "从服务器2下载校验文件：md5sum.txt" >> $LOG_FILE
	wget --user-agent="$UA" --no-check-certificate --timeout=20 -qO - $url_cdn/$binarysel/md5sum.txt > /tmp/clash_binary/md5sum2.txt
	if [ "$?" != "0" ];then
		echo_date "md5sum2.txt下载失败！" >> $LOG_FILE
		md5sum2_ok=0
	else
		md5sum2_ok=1
		echo_date "md5sum2.txt下载成功..." >> $LOG_FILE
	fi

	if [ "$md5sum_ok" == "1" ] && [ "$md5sum2_ok" == "1" ]; then
		echo_date "对比md5sum与md5sum2" >> $LOG_FILE
		cd /tmp/clash_binary
		MD5_1=$(cat md5sum.txt|awk '{print $1}')
		MD5_2=$(cat md5sum2.txt|awk '{print $1}')
		if [ "$MD5_1"x = "$MD5_2"x ]; then
			echo_date "将从服务器2下载clash二进制" >> $LOG_FILE
			down_flag=2
		fi

		if [ "$MD5_1"x != "$MD5_2"x ]; then
			echo_date "将从服务器1下载clash二进制" >> $LOG_FILE
			down_flag=1
		fi	
	else
		down_flag=0
	fi
	
	echo_date "开始下载clash二进制" >> $LOG_FILE
	
	if [ "$down_flag" == "0" ]; then
		
		wget --user-agent="$UA" --no-check-certificate --timeout=20 --tries=1 ${url_main}/$binarysel/clash
		#curl -4sSk --connect-timeout 20 $url_main/$binarysel/clash > /tmp/clash_binary/clash
		if [ "$?" != "0" ];then
			echo_date "clash下载失败！" >> $LOG_FILE
			clash_ok=0
		else
			clash_ok=1
			echo_date "clash程序下载成功..." >> $LOG_FILE
		fi
	fi

	if [ "$down_flag" == "1" ]; then
		
		wget --user-agent="$UA" --no-check-certificate --timeout=20 --tries=1 ${url_main}/$binarysel/clash
		#curl -4sSk --connect-timeout 20 $url_main/$binarysel/clash > /tmp/clash_binary/clash
		if [ "$?" != "0" ];then
			echo_date "clash下载失败！" >> $LOG_FILE
			clash_ok=0
		else
			clash_ok=1
			echo_date "clash程序下载成功..." >> $LOG_FILE
		fi
	fi

	if [ "$down_flag" == "2" ]; then
		wget --user-agent="$UA" --no-check-certificate --timeout=20 --tries=1 $url_cdn/$binarysel/clash
		#curl -4sSk --connect-timeout 20 $url_main/$binarysel/clash > /tmp/clash_binary/clash
		if [ "$?" != "0" ];then
			echo_date "clash下载失败！" >> $LOG_FILE
			clash_ok=0
		else
			clash_ok=1
			echo_date "clash程序下载成功..." >> $LOG_FILE
		fi
	fi

	if [ "$md5sum_ok" == "1" ] && [ "$clash_ok" == "1" ]; then
		check_md5sum
	else
		echo_date "下载失败，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}

check_md5sum(){
	cd /tmp/clash_binary
	echo_date "校验下载的文件!" >> $LOG_FILE
	clash_LOCAL_MD5=$(md5sum clash|awk '{print $1}')
	clash_ONLINE_MD5=$(cat md5sum.txt|awk '{print $1}')
	if [ "$clash_LOCAL_MD5"x = "$clash_ONLINE_MD5"x ]; then
		echo_date "文件校验通过!" >> $LOG_FILE
		replace_binary
	else
		echo_date "校验未通过，可能是下载过程出现了什么问题，请检查你的网络！" >> $LOG_FILE
		rm -rf /tmp/clash_binary/*
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}
replace_binary(){
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
}

move_binary(){
	echo_date "开始替换clash二进制文件... " >> $LOG_FILE
	mv /tmp/clash_binary/clash /koolshare/bin/clash
	chmod +x /koolshare/bin/clash
	clash_LOCAL_VER=`/koolshare/bin/clash -v 2>/dev/null | head -n 1 | cut -d " " -f2`
	[ -n "$clash_LOCAL_VER" ] && dbus set merlinclash_clash_version="$clash_LOCAL_VER"
	echo_date "clash二进制文件替换成功... " >> $LOG_FILE
}

start_clash(){
	#echo_date "开启clash进程... " >> $LOG_FILE
	#cd /koolshare/bin
	#export GOGC=30
	#echo_date "启用$yamlname YAML配置" >> $LOG_FILE 
	#/koolshare/bin/clash -d /koolshare/merlinclash/ -f $yamlpath >/dev/null 2>/tmp/upload/clash_error.log &
	#local i=10
	#until [ -n "$clashPID" ]
	#do
	#	i=$(($i-1))
	#	clashPID=$(pidof clash)
	#	if [ "$i" -lt 1 ];then
	#		echo_date "clash进程启动失败！" >> $LOG_FILE
	#		close_in_five
	#	fi
	#	sleep 1
	#done
	#echo_date clash启动成功，pid：$clashPID >> $LOG_FILE
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
10)
	echo "" > $LOG_FILE
	http_response "$1"
	echo_date "获取远程服务器clash版本号" >> $LOG_FILE
	get_binary_history >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE	
	;;
11)
	echo "替换clash二进制" > $LOG_FILE
	http_response "$1"
	replace_clash_binary >> $LOG_FILE 2>&1
	echo BBABBBBC >> $LOG_FILE
	;;
esac