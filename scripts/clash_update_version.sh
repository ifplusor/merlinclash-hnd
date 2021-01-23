#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
http_response "$1"
mcflag=$merlinclash_flag
if [ "$mcflag" == "HND" ]; then
	url_main="https://raw.githubusercontent.com/flyhigherpi/merlinclash_hnd/master"
else
	url_main="https://raw.githubusercontent.com/flyhigherpi/merlinclash_384/master"
fi
#merlinclash_patch_version 补丁包版本


update_mc(){
	rm -rf $LOG_FILE
	rm -rf /tmp/upload/version.txt
	echo_date 检查版本过程中请不要刷新本页面或者关闭路由等，不然可能导致问题！ >> $LOG_FILE
	echo_date 检查服务器登记版本号... >> $LOG_FILE
	#merlinclash_version_web1=`curl -4sk --connect-timeout 5 $url_main/version.txt | sed -n 1p`
	curl -4sk --connect-timeout 5 $url_main/version.txt > /tmp/upload/version.txt
	if [ "$?" == "0" ];then
		if [ -z "`cat /tmp/upload/version.txt`" ];then 
			echo_date "获取服务器版本文件失败！" >> $LOG_FILE
			echo BBABBBBC >> $LOG_FILE
			exit 1
		fi
		if [ -n "`cat /tmp/upload/version.txt|grep "<"`" ];then
			echo_date "error | 获取服务器版本文件失败！" >> $LOG_FILE
			echo BBABBBBC >> $LOG_FILE
			exit 1
		fi
		if [ -n "`cat /tmp/upload/version.txt|grep "404"`" ];then
			echo_date "error:404 | 获取服务器版本文件失败！" >> $LOG_FILE
			echo BBABBBBC >> $LOG_FILE
			exit 1
		fi
		if [ -n "$(cat /tmp/upload/version.txt|grep "500")" ];then
			echo_date "error:500 | 获取服务器版本文件失败！" >> $LOG_FILE
			echo BBABBBBC >> $LOG_FILE
			exit 1
		fi

		merlinclash_version_web1=$(cat /tmp/upload/version.txt | sed -n 1p)
	else
		echo_date "获取规则文件最新版本信息失败！" >> $LOG_FILE
		echo BBABBBBC >> $LOG_FILE
		exit 1
	fi

	echo_date 版本号内容为：$merlinclash_version_web1 >> $LOG_FILE
	#检查版本号内容是否合法
	





	mcversion_web=$(echo $merlinclash_version_web1 | awk -F"-" '{print $1}')
	patchversion_web=$(echo $merlinclash_version_web1 | awk -F"-" '{print $2}')

	if [ -n "$mcversion_web" ];then
		echo_date 检测到服务器登记版本号：$mcversion_web >> $LOG_FILE
		echo_date 检测到服务器登记补丁包版本号：$patchversion_web >> $LOG_FILE
		merlinclash_version_web=$mcversion_web
		dbus set merlinclash_version_web=$merlinclash_version_web
		mcvl=$(echo $merlinclash_version_local | awk -F"." '{print $1}')
		echo_date 本地版本号为：$mcvl-$merlinclash_patch_version >> $LOG_FILE
		if [ -z "$merlinclash_patch_version" ]; then
			echo_date "未装过补丁，将补丁版本赋初始值000" >> $LOG_FILE		
			merlinclash_patch_version="000"
			dbus set merlinclash_patch_version=$merlinclash_patch_version		
		fi
		mpvl=$merlinclash_patch_version
		if [ "$mcvl" != "$merlinclash_version_web" ];then
			echo_date 服务器登记版本号："$merlinclash_version_web" 和本地版本号："$mcvl" 不同！ >> $LOG_FILE
			echo_date "关注频道下载最新版本：https://t.me/merlinclashcat" >> $LOG_FILE			
		else
			echo_date 服务器登记版本号："$merlinclash_version_web" 和本地版本号："$mcvl" 相同！ >> $LOG_FILE
			echo_date 检查补丁包版本号 >> $LOG_FILE
			if [ "$patchversion_web" != "000" ];then
				if [ "$mpvl" != "$patchversion_web" ];then
					echo_date 服务器登记补丁包版本号："$patchversion_web" 和本地版本号："$mpvl" 不同！ >> $LOG_FILE
					echo_date "关注频道下载最新补丁包：https://t.me/merlinclashcat" >> $LOG_FILE	
				else
					echo_date 服务器登记补丁包版本号："$patchversion_web" 和本地版本号："$mpvl" 相同！ >> $LOG_FILE
				fi
			else
				echo_date "暂无补丁包" >> $LOG_FILE
			fi		
		fi
	else
		echo_date 没有检测到服务器登记版本号,访问github服务器可能有点问题！>> $LOG_FILE
		echo_date 尝试用redir-host+模式再试 >> $LOG_FILE
	fi
}

case $2 in
update)
	update_mc >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	;;
esac
