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
subscription_type="3"
dictionary=/koolshare/merlinclash/yaml_bak/subscription.txt
updateflag=""
mcflag=$merlinclash_flag

start_online_update(){
	
	updateflag="start_online_update"
	
	merlinc_link=$(echo $merlinclash_links2 | sed 's/%0A/%7C/g')
	
	upname_tmp="$merlinclash_uploadrename2"
		#echo_date "订阅文件重命名为：$upname_tmp" >> $LOG_FILE
	time=$(date "+%Y%m%d-%H%M%S")
	newname=$(echo $time | awk -F'-' '{print $2}')
	echo_date "subconverter进程：$(pidof subconverter)" >> $LOG_FILE
	echo_date "即将开始转换，需要一定时间，请等候处理" >> $LOG_FILE
	sleep 3s
	_name="Ne_"
	links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG.ini&include=&exclude=&append_type=false&emoji=true&udp=false&fdn=true&sort=true&scv=false&tfo=false"
	
	echo_date "生成订阅链接：$links" >> $LOG_FILE
	if [ -n "$upname_tmp" ]; then
		upname="$_name$upname_tmp.yaml"
	else
		upname="$_name$newname.yaml"
	fi
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online.ini"
			#echo_date merlinclash_link=$merlinc_link >> $LOG_FILE
			#wget下载文件
			#wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$links"
			UA='Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36';
			curl --user-agent "$UA" --connect-timeout 30 -s "$links" > /tmp/upload/$upname
			if [ "$?" == "0" ];then
				echo_date "检查文件完整性" >> $LOG_FILE
				if [ -z "$(cat /tmp/upload/$upname)" ];then 
					echo_date "获取clash配置文件失败！" >> $LOG_FILE
					failed_warning_clash
				else
					echo_date "检查下载是否正确" >> $LOG_FILE
					local blank=$(cat /tmp/upload/$upname | grep -E " |The following link doesn't contain any valid node info")
					if [ -n "$blank" ]; then
						echo_date "curl下载出错，尝试更换wget进行下载..." >> $LOG_FILE
						rm -rf /tmp/upload/$upname
						wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$links"
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
	#fi
}

start_regular_update(){
	#$name $type $link $clashtarget $acltype $emoji $udp $appendtype $sort $fnd $include $exclude $scv $tfo
	#$1    $2    $3    $4           $5       $6      $7    $8         $9   ${10} ${11}    ${12}   ${13} ${14}
	
	#merlinc_link=$3	
	merlinc_link=$(echo $3 | sed 's/%0A/%7C/g')
	upname_tmp=$1

	echo_date "订阅地址是：$merlinc_link"
	echo_date "配置名是：$upname_tmp"
	echo_date "subconverter进程：$(pidof subconverter)" >> $LOG_FILE
	echo_date "即将开始转换，需要一定时间，请等候处理" >> $LOG_FILE
	sleep 3s
	_name="Ne_"
	links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG.ini&include=&exclude=&append_type=false&emoji=true&udp=false&fdn=true&sort=true&scv=false&tfo=false"
	
	echo_date "生成订阅链接：$links" >> $LOG_FILE
	upname="${_name}${upname_tmp}.yaml"
		
	#wget下载文件
	#wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$links"
	UA='Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36';
	curl --user-agent "$UA" --connect-timeout 30 -s "$links" > /tmp/upload/$upname
	if [ "$?" == "0" ];then
		echo_date "检查文件完整性" >> $LOG_FILE
		if [ -z "$(cat /tmp/upload/$upname)" ];then 
			echo_date "获取clash配置文件失败！" >> $LOG_FILE
			failed_warning_clash
		else
			echo_date "检查下载是否正确" >> $LOG_FILE
			local blank=$(cat /tmp/upload/$upname | grep -E " |The following link doesn't contain any valid node info")
			if [ -n "$blank" ]; then
				echo_date "curl下载出错，尝试更换wget进行下载..." >> $LOG_FILE
				rm -rf /tmp/upload/$upname
				wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$links"
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
}
start_online_update_384(){
	addr=$merlinclash_subconverter_addr
	updateflag="start_online_update"
	
	merlinc_link=$(echo $merlinclash_links2 | sed 's/%0A/%7C/g')
	
	upname_tmp="$merlinclash_uploadrename2"
		#echo_date "订阅文件重命名为：$upname_tmp" >> $LOG_FILE
	time=$(date "+%Y%m%d-%H%M%S")
	newname=$(echo $time | awk -F'-' '{print $2}')
	#echo_date "subconverter进程：$(pidof subconverter)" >> $LOG_FILE
	echo_date "即将开始转换，需要一定时间，请等候处理" >> $LOG_FILE
	sleep 1s
	_name="Ne_"
	links="${addr}sub?target=clash&new_name=true&url=$merlinc_link&insert=fals&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG.ini&include=&exclude=&append_type=false&emoji=true&udp=false&fdn=true&sort=true&scv=false&tfo=false"
	
	echo_date "生成订阅链接：$links" >> $LOG_FILE
	if [ -n "$upname_tmp" ]; then
		upname="$_name$upname_tmp.yaml"
	else
		upname="$_name$newname.yaml"
	fi
			#links="https://subcon.dlj.tf/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online.ini"
			#echo_date merlinclash_link=$merlinc_link >> $LOG_FILE
			#wget下载文件
			#wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$links"
			UA='Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36';
			curl --user-agent "$UA" --connect-timeout 30 -s "$links" > /tmp/upload/$upname
			if [ "$?" == "0" ];then
				echo_date "检查文件完整性" >> $LOG_FILE
				if [ -z "$(cat /tmp/upload/$upname)" ];then 
					echo_date "获取clash配置文件失败！" >> $LOG_FILE
					failed_warning_clash
				else
					echo_date "检查下载是否正确" >> $LOG_FILE
					local blank=$(cat /tmp/upload/$upname | grep -E " |The following link doesn't contain any valid node info")
					if [ -n "$blank" ]; then
						echo_date "curl下载出错，尝试更换wget进行下载..." >> $LOG_FILE
						rm -rf /tmp/upload/$upname
						wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$links"
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
	#fi
}

start_regular_update_384(){
	#$name $type $link $clashtarget $acltype $emoji $udp $appendtype $sort $fnd $include $exclude $scv $tfo
	#$1    $2    $3    $4           $5       $6      $7    $8         $9   ${10} ${11}    ${12}   ${13} ${14}
	addr="$4"
	#merlinc_link=$3	
	merlinc_link=$(echo $3 | sed 's/%0A/%7C/g')
	upname_tmp=$1
	echo_date "订阅地址是：$merlinc_link"
	echo_date "配置名是：$upname_tmp"
	#echo_date "subconverter进程：$(pidof subconverter)" >> $LOG_FILE
	echo_date "即将开始转换，需要一定时间，请等候处理" >> $LOG_FILE
	sleep 1s
	_name="Ne_"
	links="${addr}sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG.ini&include=&exclude=&append_type=false&emoji=true&udp=false&fdn=true&sort=true&scv=false&tfo=false"
	
	echo_date "生成订阅链接：$links" >> $LOG_FILE
	upname="${_name}${upname_tmp}.yaml"
		
	#wget下载文件
	#wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$links"
	UA='Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36';
	curl --user-agent "$UA" --connect-timeout 30 -s "$links" > /tmp/upload/$upname
	if [ "$?" == "0" ];then
		echo_date "检查文件完整性" >> $LOG_FILE
		if [ -z "$(cat /tmp/upload/$upname)" ];then 
			echo_date "获取clash配置文件失败！" >> $LOG_FILE
			failed_warning_clash
		else
			echo_date "检查下载是否正确" >> $LOG_FILE
			local blank=$(cat /tmp/upload/$upname | grep -E " |The following link doesn't contain any valid node info")
			if [ -n "$blank" ]; then
				echo_date "curl下载出错，尝试更换wget进行下载..." >> $LOG_FILE
				rm -rf /tmp/upload/$upname
				wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$links"
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
}
write_dictionary(){
	if [ -f "$dictionary" ]; then
		name_tmp=$(cat $dictionary | grep -w -n "$upname" | awk -F ":" '{print $1}')
		#定位配置名行数，存在，则覆写；不存在，则新增 -w全字符匹配
		if [ -n "$name_tmp" ]; then
			if [ "$updateflag" == "start_online_update" ]; then
				echo_date "【小白一键订阅】配置名存在，覆写" >> $LOG_FILE
				sed -i "$name_tmp d" $dictionary
				if [ "$mcflag" == "HND" ]; then
					echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\" >> $dictionary
				else
					echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"addr\":\"$addr\" >> $dictionary
				fi
				#sed -i "s/^\"name\":\"$upname\",*$/^\"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"clashtarget\":\"$merlinclash_clashtarget\",\"acltype\":\"$merlinclash_acl4ssrsel\",\"emoji\":\"$merlinclash_subconverter_emoji\",\"udp\":\"$merlinclash_subconverter_udp\",\"appendtype\":\"$merlinclash_subconverter_append_type\",\"sort\":\"$merlinclash_subconverter_sort\",\"fnd\":\"$merlinclash_subconverter_fdn\",\"include\":\"$merlinclash_subconverter_include\",\"exclude\":\"$merlinclash_subconverter_exclude\",\"scv\":\"$merlinclash_subconverter_scv\",\"tfo\":\"$merlinclash_subconverter_tfo\"/g" $dictionary
			fi
		else
			#新增
			echo_date "配置名不存在，新增" >> $LOG_FILE
			if [ "$mcflag" == "HND" ]; then
				echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\" >> $dictionary
			else	
				echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"addr\":\"$addr\" >> $dictionary
			fi
		fi
	else
		#为初次订阅，直接写入
		echo_date "初次订阅，直接写入" >> $LOG_FILE
		if [ "$mcflag" == "HND" ]; then
			echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\" >> $dictionary
		else
			echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"addr\":\"$addr\" >> $dictionary
		fi
	fi
	
}

check_yamlfile(){
	#通过获取的文件是否存在port: Rule: Proxy: Proxy Group: 标题头确认合法性
	para1=$(sed -n '/^port:/p' /tmp/upload/$upname)
	para1_1=$(sed -n '/^mixed-port:/p' /tmp/upload/$upname)
	para2=$(sed -n '/^socks-port:/p' /tmp/upload/$upname)
	#para3=$(sed -n '/^mode:/p' /tmp/upload/$upname)
	#para4=$(sed -n '/^name:/p' /tmp/upload/upload.yaml)
	#para5=$(sed -n '/^type:/p' /tmp/upload/upload.yaml)

	if ([ ! -n "$para1" ] && [ ! -n "$para1_1" ]) && [ ! -n "$para2" ]; then
		echo_date "clash配置文件不是合法的yaml文件，转换格式可能有误" >> $LOG_FILE
		rm -rf /tmp/upload/$upname
	else
		echo_date "clash配置文件检查通过" >> $LOG_FILE
		flag=1
	fi
}

failed_warning_clash(){
	rm -rf /tmp/upload/$upname
	echo_date "本地获取文件失败！！！" >> $LOG_FILE
	#echo_date "因使用github远程规则，尝试使用redir-host+模式订阅" >> $LOG_FILE
	sc_process=$(pidof subconverter)
	if [ -n "$sc_process" ]; then
		echo_date 关闭subconverter进程... >> $LOG_FILE
		killall subconverter >/dev/null 2>&1
	fi
	echo_date "===================================================================" >> $LOG_FILE
	echo BBABBBBC
	exit 1
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
17)
	#set_lock
	if [ "$mcflag" == "HND" ]; then
		echo "" > $LOG_FILE
		http_response "$1"
		echo_date "小白一键转换订阅HND" >> $LOG_FILE
		#20200802启动subconverter进程
		/koolshare/bin/subconverter >/dev/null 2>&1 &
		start_online_update >> $LOG_FILE
		sc_process=$(pidof subconverter)
		if [ -n "$sc_process" ]; then
			echo_date 关闭subconverter进程... >> $LOG_FILE
			killall subconverter >/dev/null 2>&1
		fi
		echo BBABBBBC >> $LOG_FILE
	else
		
		echo "" > $LOG_FILE
		http_response "$1"
		echo_date "小白一键转换订阅384" >> $LOG_FILE
		start_online_update_384 >> $LOG_FILE
		echo BBABBBBC >> $LOG_FILE
	fi
	;;
3)
	if [ "$mcflag" == "HND" ]; then
		echo_date "小白一键定时订阅HND" >> $LOG_FILE
		#20200802启动subconverter进程
		/koolshare/bin/subconverter >/dev/null 2>&1 &
		#$name $type $link 
		#$1    $2    $3    
		start_regular_update "$1" "$2" "$3" >> $LOG_FILE
		sc_process=$(pidof subconverter)
		if [ -n "$sc_process" ]; then
			echo_date 关闭subconverter进程... >> $LOG_FILE
			killall subconverter >/dev/null 2>&1
		fi
		echo BBABBBBC >> $LOG_FILE
	else
		echo_date "小白一键定时订阅384" >> $LOG_FILE
		#$name $type $link $addr 
		#$1    $2    $3    $4
		start_regular_update_384 "$1" "$2" "$3" "$4" >> $LOG_FILE
		echo BBABBBBC >> $LOG_FILE
	fi
	;;
esac

