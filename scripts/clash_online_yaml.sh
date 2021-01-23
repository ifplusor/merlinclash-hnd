#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt

rm -rf /tmp/upload/merlinclash_log.txt
rm -rf /tmp/upload/*.yaml
LOCK_FILE=/var/lock/yaml_online_update.lock
flag=0
upname=""
upname_tmp=""
subscription_type="1"
dictionary=/koolshare/merlinclash/yaml_bak/subscription.txt
updateflag=""

start_online_update(){
	updateflag="start_online_update"
	merlinc_link=$merlinclash_links
	LINK_FORMAT=$(echo "$merlinc_link" | grep -E "^http://|^https://")
	echo_date "订阅地址是：$LINK_FORMAT"
	if [ -z "$LINK_FORMAT" ]; then
		echo_date "订阅地址错误！检测到你输入的订阅地址并不是标准网址格式！"
		sleep 2
		echo_date "退出订阅程序" >> $LOG_FILE
	else
		upname_tmp=$merlinclash_uploadrename
		
		time=$(date "+%Y%m%d-%H%M%S")
		newname=$(echo $time | awk -F'-' '{print $2}')
		if [ -n "$upname_tmp" ]; then
			upname=$upname_tmp.yaml
		else
			upname=$newname.yaml
		fi
		echo_date "上传文件重命名为：$upname" >> $LOG_FILE
		#echo_date merlinclash_link=$merlinc_link >> $LOG_FILE
		#wget下载文件
		#wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$merlinc_link"
		curl --connect-timeout 20 -s $merlinc_link > /tmp/upload/$upname
		if [ "$?" == "0" ];then
			echo_date "检查文件完整性" >> $LOG_FILE
       		if [ -z "$(cat /tmp/upload/$upname)" ];then 
				echo_date "获取clash配置文件失败！" >> $LOG_FILE
				failed_warning_clash
			else
				#虽然为0但是还是要检测下是否下载到正确的内容
				echo_date "检查下载是否正确" >> $LOG_FILE
				
					#订阅地址有跳转
					local blank=$(cat /tmp/upload/$upname | grep -E " |Redirecting|301")
					if [ -n "$blank" ]; then
						echo_date "订阅链接可能有跳转，尝试更换wget进行下载..." >> $LOG_FILE
						rm /tmp/upload/$upname
						if [ -n $(echo $merlinc_link | grep -E "^https") ]; then
							wget --no-check-certificate --timeout=15 -qO /tmp/upload/$upname $merlinc_link
							#curl --connect-timeout 10 -s $mclink > /tmp/clash_subscribe_file1.txt
							
						else
							wget --timeout=15 -qO /tmp/upload/$upname $merlinc_link
							
						fi
					fi
					#下载为空...
					if [ -z "$(cat /tmp/upload/$upname)" ]; then
						echo_date "下载内容为空..."
						failed_warning_clash
					fi
				echo_date "已获取clash配置文件" >> $LOG_FILE
				echo_date "yaml文件合法性检查" >> $LOG_FILE
				check_yamlfile
				if [ $flag == "1" ]; then
				#后台执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/koolshare/merlinclash/并命名为upload.yaml
					echo_date "后台执行yaml文件处理工作" >> $LOG_FILE
					sh /koolshare/scripts/clash_yaml_sub.sh >/dev/null 2>&1 &
					#20200803写入字典
					write_dictionary					
				else
					echo_date "yaml文件格式不合法" >> $LOG_FILE
				fi
			fi
		else			
			failed_warning_clash
		fi		
	fi
}

start_regular_update(){
	updateflag="start_regular_update"
	merlinc_link=$2
	upname=$1
	upname=$upname.yaml
	#wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$merlinc_link"
	curl --connect-timeout 20 -s $merlinc_link > /tmp/upload/$upname
	if [ "$?" == "0" ];then
		echo_date "检查文件完整性" >> $LOG_FILE
      	if [ -z "$(cat /tmp/upload/$upname)" ];then 
			echo_date "获取clash配置文件失败！" >> $LOG_FILE
			failed_warning_clash
		else
			#虽然为0但是还是要检测下是否下载到正确的内容
			echo_date "检查下载是否正确" >> $LOG_FILE
			#订阅地址有跳转
			local blank=$(cat /tmp/upload/$upname | grep -E " |Redirecting|301")
			if [ -n "$blank" ]; then
				echo_date "订阅链接可能有跳转，尝试更换wget进行下载..." >> $LOG_FILE
				rm /tmp/upload/$upname
				if [ -n $(echo $merlinc_link | grep -E "^https") ]; then
					wget --no-check-certificate --timeout=20 -qO /tmp/upload/$upname $merlinc_link
					#curl --connect-timeout 10 -s $mclink > /tmp/clash_subscribe_file1.txt
					
				else
					wget --timeout=20 -qO /tmp/upload/$upname $merlinc_link					
				fi
			fi
			#下载为空...
			if [ -z "$(cat /tmp/upload/$upname)" ]; then
				echo_date "下载内容为空..."  >> $LOG_FILE
				failed_warning_clash
			fi
			echo_date "已获取clash配置文件" >> $LOG_FILE
			echo_date "yaml文件合法性检查" >> $LOG_FILE
			check_yamlfile
			if [ $flag == "1" ]; then
			#后台执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/koolshare/merlinclash/并命名为upload.yaml
				echo_date "后台执行yaml文件处理工作" >> $LOG_FILE
				sh /koolshare/scripts/clash_yaml_sub.sh >/dev/null 2>&1 &
				#20200803写入字典
				write_dictionary
				
			else
				echo_date "yaml文件格式不合法" >> $LOG_FILE
			fi
		fi
	else			
		failed_warning_clash
	fi		
}

write_dictionary(){
	if [ -f "$dictionary" ]; then
		name_tmp=$(cat $dictionary | grep -w -n "$upname" | awk -F ":" '{print $1}')
		#定位配置名行数，存在，则覆写；不存在，则新增 -w全字符匹配
		if [ -n "$name_tmp" ]; then
			if [ "$updateflag" == "start_online_update" ]; then			
				echo_date "【在线clash订阅】配置名存在，覆写" >> $LOG_FILE
				sed -i "$name_tmp d" $dictionary
				echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\" >> $dictionary
				#sed -i "$name_tmp i \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\" " $dictionary
				#sed -i "s?^\"name\":\"$upname\",*$""?^\"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\"?g" $dictionary
			fi
		else
			#新增
			echo_date "配置名不存在，新增" >> $LOG_FILE
			echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\" >> $dictionary
		fi
	else
		#为初次订阅，直接写入
		echo_date "初次订阅，直接写入" >> $LOG_FILE
		echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\" >> $dictionary
	fi
	
}
failed_warning_clash(){
	rm -rf /tmp/upload/$upname
	echo_date "获取文件失败！！请检查网络！" >> $LOG_FILE
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC
	exit 1
}

check_yamlfile(){
	#通过获取的文件是否存在port: Rule: Proxy: Proxy Group: 标题头确认合法性
	#先处理下文本
	sh /koolshare/scripts/clash_string.sh /tmp/upload/$upname
	para1=$(sed -n '/^port:/p' /tmp/upload/$upname)
	para1_1=$(sed -n '/^mixed-port:/p' /tmp/upload/$upname)
	#para2=$(sed -n '/^socks-port:/p' /tmp/upload/$upname)
	#para3=$(sed -n '/^mode:/p' /tmp/upload/$upname)
	#para4=$(sed -n '/^name:/p' /tmp/upload/upload.yaml)
	#para5=$(sed -n '/^type:/p' /tmp/upload/upload.yaml)
	proxies_line=$(cat /tmp/upload/$upname | grep -n "^proxies:" | awk -F ":" '{print $1}')
	#20200902+++++++++++++++
	#COMP 左>右，值-1；左等于右，值0；左<右，值1
	port_line=$(cat /tmp/upload/$upname | grep -n "^port:" | awk -F ":" '{print $1}')
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
		rm -rf /tmp/upload/$upname
	else
		echo_date "clash配置文件检查通过" >> $LOG_FILE
		flag=1
	fi
}
set_lock(){
	exec 233>"$LOCK_FILE"
	flock -n 233 || {
		echo_date "订阅脚本已经在运行，请稍候再试！" >> $LOG_FILE	
		unset_lock
	}
}

unset_lock(){
	flock -u 233
	rm -rf "$LOCK_FILE"
}

case $2 in
2)
	#set_lock
	echo "" > $LOG_FILE
	http_response "$1"
	echo_date "在线clash订阅" >> $LOG_FILE
	echo_date "clash订阅链接处理" >> $LOG_FILE
	start_online_update >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	#unset_lock
	;;
1)
	echo_date "clash订阅定时更新" >> $LOG_FILE
	start_regular_update "$1" "$3" >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	;;
esac

