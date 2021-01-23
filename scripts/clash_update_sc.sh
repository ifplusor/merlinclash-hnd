#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
url_main="https://raw.githubusercontent.com/flyhigherpi/merlinclash_clash_related/master/subconverter_rules"
url_back=""
yamlname=$merlinclash_yamlsel
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml
scver=""

get_latest_version(){
	rm -rf /tmp/upload/subconverterrule_latest_info.txt
	if [ -z "$merlinclash_scrule_version" ]; then
		echo_date "为SC规则文件版本赋初始值0" >> $LOG_FILE		
		merlinclash_scrule_version=0
		dbus set merlinclash_scrule_version=$merlinclash_scrule_version
		
	fi
	echo_date "SC规则文件版本为$merlinclash_scrule_version" >> $LOG_FILE
	echo_date "检测SC规则文件最新版本..." >> $LOG_FILE

	curl --connect-timeout 10 -s $url_main/lastest.txt > /tmp/upload/subconverterrule_latest_info.txt
	if [ "$?" == "0" ];then
		if [ -z "`cat /tmp/upload/subconverterrule_latest_info.txt`" ];then 
			echo_date "获取规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "`cat /tmp/upload/subconverterrule_latest_info.txt|grep "404"`" ];then
			echo_date "error:404 | 获取规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		if [ -n "$(cat /tmp/upload/subconverterrule_latest_info.txt|grep "500")" ];then
			echo_date "error:500 | 获取规则文件最新版本失败！" >> $LOG_FILE
			failed_warning_clash
		fi
		scVERSION=$(cat /tmp/upload/subconverterrule_latest_info.txt | sed 's/s//g') || 0
	
		echo_date "检测到sc规则文件最新版本：s$scVERSION" >> $LOG_FILE
		if [ ! -f "/koolshare/merlinclash/subconverter/rules/LocalAreaNetwork.list" ];then
			echo_date "规则文件丢失！重新下载！" >> $LOG_FILE
			CUR_VER="0"
		else
			CUR_VER=$merlinclash_scrule_version
			echo_date "当前已内置规则文件版本：s$CUR_VER" >> $LOG_FILE
		fi
		COMP=$(versioncmp $CUR_VER $scVERSION)
		if [ "$COMP" == "1" ];then
			[ "$CUR_VER" != "0" ] && echo_date "内置规则文件低于最新版本，开始更新..." >> $LOG_FILE
			scver=$scVERSION
			update_now s$scVERSION
		else				
			echo_date "内置规则文件已经是最新，退出更新程序!" >> $LOG_FILE
		fi
	else
		echo_date "获取规则文件最新版本信息失败！" >> $LOG_FILE
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
	rm -rf /tmp/scrule
	mkdir -p /tmp/scrule && cd /tmp/scrule

	echo_date "开始下载校验文件：md5sum.txt" >> $LOG_FILE
	wget --no-check-certificate --timeout=20 -qO - $url_main/$1/md5sum.txt > /tmp/scrule/md5sum.txt
	if [ "$?" != "0" ];then
		echo_date "md5sum.txt下载失败！" >> $LOG_FILE
		md5sum_ok=0
	else
		md5sum_ok=1
		echo_date "md5sum.txt下载成功..." >> $LOG_FILE
	fi
	
	echo_date "开始下载规则文件" >> $LOG_FILE
	#wget --no-check-certificate --timeout=20 --tries=1 $url_main/$1/Clash.tar.gz
	wget --no-check-certificate --timeout=20 --tries=1 $url_main/$1/rules.tar.gz
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
	cd /tmp/scrule
	echo_date "校验下载的文件!" >> $LOG_FILE
	#sc_LOCAL_MD5=$(md5sum Clash.tar.gz|awk '{print $1}')
	sc_LOCAL_MD5=$(md5sum rules.tar.gz|awk '{print $1}')
	echo_date "已下载常规规则文件md5值是：$sc_LOCAL_MD5" >> $LOG_FILE

	
	sc_ONLINE_MD5=$(cat md5sum.txt|awk '{print $1}')
	echo_date "服务器文件记录的md5值是：$sc_ONLINE_MD5" >> $LOG_FILE
	if [ "$sc_LOCAL_MD5"x = "$sc_ONLINE_MD5"x ]; then
		echo_date "文件校验通过!" >> $LOG_FILE
		install_scrule
	else
		echo_date "校验未通过，可能是下载过程出现了什么问题，请检查你的网络！" >> $LOG_FILE
		echo_date "===================================================================" >> $LOG_FILE
		echo BBABBBBC
		exit 1
	fi
}

install_scrule(){
	echo_date "开始覆盖最新规则!" >> $LOG_FILE
	move_scrule
}

move_scrule(){
	echo_date "开始替换规则文件... " >> $LOG_FILE
	#解压缩
	cd /tmp/scrule
	#tar -zxvf Clash.tar.gz >/dev/null 2>&1
	tar -zxvf rules.tar.gz >/dev/null 2>&1
	if [ "$?" == "0" ];then
		echo_date 解压完成！>> $LOG_FILE
		#cp -rf /tmp/scrule/Clash/* /koolshare/merlinclash/subconverter/rules/ACL4SSR/Clash/
		#chmod +x /koolshare/merlinclash/subconverter/rules/ACL4SSR/Clash/*
		cp -rf /tmp/scrule/rules/* /koolshare/merlinclash/subconverter/rules/
		chmod +x /koolshare/merlinclash/subconverter/rules/*
		dbus set merlinclash_scrule_version="$scver"

		echo_date "规则文件文件替换成功... " >> $LOG_FILE
		echo_date "使用subconverter转换订阅时将使用新的规则文件... " >> $LOG_FILE
		cd
		rm -rf /tmp/scrule
	else
		echo_date 解压错误，错误代码："$?"！ >> $LOG_FILE
		echo_date 估计是错误或者不完整的更新包！>> $LOG_FILE
		echo_date 删除相关文件并退出... >> $LOG_FILE
		cd
		rm -rf /tmp/scrule
		echo BBABBBBC >> $LOG_FILE
		exit 
	fi

}

case $2 in
18)
	echo "更新SC规则文件" > $LOG_FILE
	http_response "$1"
	echo_date "===================================================================" >> $LOG_FILE
	echo_date "                规则文件更新(基于sadog v2ray程序更新修改)" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	get_latest_version >> $LOG_FILE 2>&1
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	;;
esac