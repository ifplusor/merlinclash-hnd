#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
url_main="https://raw.githubusercontent.com/flyhigherpi/merlinclash_clash_related/master/proxy-group"
#https://cdn.jsdelivr.net/gh/flyhigherpi/merlinclash_clash_related/proxy-group/common_rule/lastest.txt
url_cdn="https://cdn.jsdelivr.net/gh/flyhigherpi/merlinclash_clash_related/proxy-group"
url_back=""
yamlname=$merlinclash_yamlsel
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml
pgver=""
ggver=""
flag="" # 0为常规规则文件，1为游戏规则文件

get_latest_version(){
	rm -rf /tmp/upload/proxygroup_latest_info.txt
	flag="0"
	if [ -z "$merlinclash_proxygroup_version" ]; then
		echo_date "为常规规则文件版本赋初始值0" >> $LOG_FILE		
		merlinclash_proxygroup_version=0
		dbus set merlinclash_proxygroup_version=$merlinclash_proxygroup_version
		
	fi
	echo_date "常规规则文件版本为$merlinclash_proxygroup_version" >> $LOG_FILE
	echo_date "检测常规规则文件最新版本..." >> $LOG_FILE
	#插入hosts,免得raw.githubusercontent.com解析失败
	#if grep -q "raw.githubusercontent.com" /etc/hosts; then
	#	echo_date "已存在raw.githubusercontent.com的host记录" >> $LOG_FILE
	#else
	#	echo_date "创建raw.githubusercontent.com的host记录" >> $LOG_FILE
	#	sed -i '$a\151.101.64.133 raw.githubusercontent.com' /etc/hosts
	#fi
	#set_firewall

	curl --connect-timeout 10 -s $url_main/common_rule/lastest.txt > /tmp/upload/proxygroup_latest_info.txt
	if [ "$?" == "0" ];then
		if [ -z "`cat /tmp/upload/proxygroup_latest_info.txt`" ];then 
			echo_date "获取常规规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "`cat /tmp/upload/proxygroup_latest_info.txt|grep "404"`" ];then
			echo_date "error:404 | 获取常规规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "$(cat /tmp/upload/proxygroup_latest_info.txt|grep "500")" ];then
			echo_date "error:500 | 获取常规规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		pgVERSION=$(cat /tmp/upload/proxygroup_latest_info.txt | sed 's/v//g') || 0
	
		echo_date "检测到常规规则文件最新版本：v$pgVERSION" >> $LOG_FILE
		if [ ! -f "/koolshare/merlinclash/yaml_basic/proxy-group.yaml" ];then
			echo_date "常规规则文件丢失！重新下载！" >> $LOG_FILE
			CUR_VER="0"
		else
			CUR_VER=$merlinclash_proxygroup_version
			echo_date "当前已内置常规规则文件版本：v$CUR_VER" >> $LOG_FILE
		fi
		COMP=$(versioncmp $CUR_VER $pgVERSION)
		if [ "$COMP" == "1" ];then
			[ "$CUR_VER" != "0" ] && echo_date "内置常规规则文件低于最新版本，开始更新..." >> $LOG_FILE
			pgver=$pgVERSION
			update_now common_rule v$pgVERSION
		else				
			echo_date "内置常规规则文件已经是最新，退出更新程序!" >> $LOG_FILE
		fi
	else
		echo_date "获取常规规则文件最新版本信息失败！" >> $LOG_FILE
		failed_warning_clash
	fi
}

get_latest_gameversion(){
	rm -rf /tmp/upload/proxygroup_latest_gameinfo.txt
	flag="1"
	if [ -z "$merlinclash_proxygame_version" ]; then
		echo_date "为游戏规则文件版本赋初始值0" >> $LOG_FILE		
		merlinclash_proxygame_version=0
		dbus set merlinclash_proxygame_version=$merlinclash_proxygame_version
		
	fi
	echo_date "规则文件版本为$merlinclash_proxygame_version" >> $LOG_FILE
	echo_date "检测规则文件最新版本..." >> $LOG_FILE

	#set_firewall

	curl --connect-timeout 10 -s $url_main/game_rule/gamelastest.txt > /tmp/upload/proxygroup_latest_gameinfo.txt
	if [ "$?" == "0" ];then
		if [ -z "`cat /tmp/upload/proxygroup_latest_gameinfo.txt`" ];then 
			echo_date "获取游戏规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "`cat /tmp/upload/proxygroup_latest_gameinfo.txt|grep "404"`" ];then
			echo_date "error:404 | 获取游戏规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "$(cat /tmp/upload/proxygroup_latest_gameinfo.txt|grep "500")" ];then
			echo_date "error:500 | 获取游戏规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		ggVERSION=$(cat /tmp/upload/proxygroup_latest_gameinfo.txt | sed 's/g//g') || 0
	
		echo_date "检测到游戏规则文件最新版本：g$ggVERSION" >> $LOG_FILE
		if [ ! -f "/koolshare/merlinclash/yaml_basic/proxy-group-game.yaml" ];then
			echo_date "规则文件丢失！重新下载！" >> $LOG_FILE
			CUR_VER="0"
		else
			CUR_VER=$merlinclash_proxygame_version
			echo_date "当前已内置规则文件版本：g$CUR_VER" >> $LOG_FILE
		fi
		COMP=$(versioncmp $CUR_VER $ggVERSION)
		if [ "$COMP" == "1" ];then
			[ "$CUR_VER" != "0" ] && echo_date "内置游戏规则文件低于最新版本，开始更新..." >> $LOG_FILE
			ggver=$ggVERSION
			update_now game_rule g$ggVERSION
		else				
			echo_date "内置游戏规则文件已经是最新，退出更新程序!" >> $LOG_FILE
		fi
	else
		echo_date "获取游戏规则文件最新版本信息失败！" >> $LOG_FILE
		failed_warning_clash
	fi
}

failed_warning_clash(){
	echo_date "获取文件失败！！请检查网络！注意raw.githubusercontent.com的DNS解析结果" >> $LOG_FILE
	echo_date "如属raw.githubusercontent.com的DNS解析问题，可切换到Redir-Host+模式尝试更新" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC
	exit 1
}

update_now(){
	rm -rf /tmp/proxygroup
	mkdir -p /tmp/proxygroup && cd /tmp/proxygroup

	echo_date "开始下载校验文件：md5sum.txt" >> $LOG_FILE
	wget --no-check-certificate --timeout=20 -qO - $url_main/$1/$2/md5sum.txt > /tmp/proxygroup/md5sum.txt
	if [ "$?" != "0" ];then
		echo_date "md5sum.txt下载失败！" >> $LOG_FILE
		md5sum_ok=0
	else
		md5sum_ok=1
		echo_date "md5sum.txt下载成功..." >> $LOG_FILE
	fi
	
	echo_date "开始下载规则文件" >> $LOG_FILE
	if [ "$flag" == "0" ]; then
		#wget --no-check-certificate --timeout=20 --tries=1 $url_main/$1/$2/proxy-group.yaml
		wget --no-check-certificate --timeout=20 --tries=1 $url_main/$1/$2/proxy-group.tar.gz
	fi
	if [ "$flag" == "1" ]; then
		#wget --no-check-certificate --timeout=20 --tries=1 $url_main/$1/$2/proxy-group-game.yaml
		wget --no-check-certificate --timeout=20 --tries=1 $url_main/$1/$2/proxy-group-game.tar.gz
	fi
	if [ "$?" != "0" ];then
		echo_date "规则文件下载失败！" >> $LOG_FILE
		clash_ok=0
	else
		clash_ok=1
		echo_date "规则文件下载成功..." >> $LOG_FILE
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
	cd /tmp/proxygroup
	echo_date "校验下载的文件!" >> $LOG_FILE
	if [ "$flag" == "0" ]; then
		pg_LOCAL_MD5=$(md5sum proxy-group.tar.gz|awk '{print $1}')
		echo_date "已下载常规规则文件md5值是：$pg_LOCAL_MD5" >> $LOG_FILE
	fi
	if [ "$flag" == "1" ]; then
		pg_LOCAL_MD5=$(md5sum proxy-group-game.tar.gz|awk '{print $1}')
		echo_date "已下载游戏规则文件md5值是：$pg_LOCAL_MD5" >> $LOG_FILE
	fi
	pg_ONLINE_MD5=$(cat md5sum.txt|awk '{print $1}')
	echo_date "服务器文件记录的md5值是：$pg_ONLINE_MD5" >> $LOG_FILE
	if [ "$pg_LOCAL_MD5"x = "$pg_ONLINE_MD5"x ]; then
		echo_date "文件校验通过!" >> $LOG_FILE
		install_proxygroup
	else
		echo_date "校验未通过，可能是下载过程出现了什么问题，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}

install_proxygroup(){
	echo_date "开始覆盖最新规则!" >> $LOG_FILE
	move_proxygroup
}

move_proxygroup(){
	echo_date "开始替换规则文件... " >> $LOG_FILE
	if [ "$flag" == "0" ]; then
		#解压缩
		cd /tmp/proxygroup
		tar -zxvf proxy-group.tar.gz >/dev/null 2>&1
		if [ "$?" == "0" ];then
			echo_date 解压完成！>> $LOG_FILE
			mv /tmp/proxygroup/proxy-group.yaml /koolshare/merlinclash/yaml_basic/proxy-group.yaml
			chmod +x /koolshare/merlinclash/yaml_basic/proxy-group.yaml
			dbus set merlinclash_proxygroup_version="$pgver"
		else
			echo_date 解压错误，错误代码："$?"！ >> $LOG_FILE
			echo_date 估计是错误或者不完整的更新包！>> $LOG_FILE
			echo_date 删除相关文件并退出... >> $LOG_FILE
			cd
			rm -rf /tmp/proxygroup
			echo BBABBBBC >> $LOG_FILE
			exit 
		fi
	fi
	if [ "$flag" == "1" ]; then
		#解压缩
		cd /tmp/proxygroup
		tar -zxvf proxy-group-game.tar.gz >/dev/null 2>&1
		if [ "$?" == "0" ];then
			echo_date 解压完成！>> $LOG_FILE
			mv /tmp/proxygroup/proxy-group-game.yaml /koolshare/merlinclash/yaml_basic/proxy-group-game.yaml
			chmod +x /koolshare/merlinclash/yaml_basic/proxy-group-game.yaml
			dbus set merlinclash_proxygame_version="$ggver"
		else
			echo_date 解压错误，错误代码："$?"！ >> $LOG_FILE
			echo_date 估计是错误或者不完整的更新包！>> $LOG_FILE
			echo_date 删除相关文件并退出... >> $LOG_FILE
			cd
			rm -rf /tmp/proxygroup
			echo BBABBBBC >> $LOG_FILE
			exit 
		fi
	fi
	echo_date "规则文件文件替换成功... " >> $LOG_FILE
	echo_date "使用内置订阅时将使用新的规则文件... " >> $LOG_FILE
}

case $2 in
14)
	echo "更新常规规则文件" > $LOG_FILE
	http_response "$1"
	echo_date "===================================================================" >> $LOG_FILE
	echo_date "                规则文件更新(基于sadog v2ray程序更新修改)" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	get_latest_version >> $LOG_FILE 2>&1
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	;;
19)
	echo "更新游戏规则文件" > $LOG_FILE
	http_response "$1"
	echo_date "===================================================================" >> $LOG_FILE
	echo_date "                规则文件更新(基于sadog v2ray程序更新修改)" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	get_latest_gameversion >> $LOG_FILE 2>&1
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	;;
esac