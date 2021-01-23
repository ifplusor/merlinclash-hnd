#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
#source helper.sh

eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
head_tmp=/koolshare/merlinclash/yaml_basic/head.yaml
lan_ip=$(nvram get lan_ipaddr)
rm -rf /tmp/upload/merlinclash_log.txt
rm -rf /tmp/upload/*.yaml
cp -rf /koolshare/merlinclash/yaml_basic/proxies.yaml /tmp/upload/proxies.yaml
if [ "$merlinclash_localrulesel" == "常规规则" ]; then 
	cp -rf /koolshare/merlinclash/yaml_basic/proxy-group.yaml /tmp/upload/proxy-group.yaml
	rule_version=$merlinclash_proxygroup_version
fi
if [ "$merlinclash_localrulesel" == "游戏规则" ]; then 
	cp -rf /koolshare/merlinclash/yaml_basic/proxy-group-game.yaml /tmp/upload/proxy-group-game.yaml
	rule_version=$merlinclash_proxygame_version
fi
LOCK_FILE=/var/lock/yaml_online_update.lock

flag=0
upname=""
upname_tmp=""
num=0
pronum=0
subscription_type="2"
dictionary=/koolshare/merlinclash/yaml_bak/subscription.txt
updateflag=""
mcflag=$merlinclash_flag

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

get_oneline_rule_now(){
	#20200806 新增多链接转换成一个
	updateflag="get_oneline_rule_now"
	mclinks=$(echo $merlinclash_links2 | sed 's/\\n/ /g')
	#remarks=$(echo -n "$link" | awk -F'#' '{print $2}' | sed 's/[\r\n ]//g')
	echo_date "链接：$mclinks" >> $LOG_FILE
	rm -rf /tmp/clash_subscribe_file* >/dev/null 2>&1
	for mclink in $mclinks; do
		echo_date "订阅链接是$mclink" >> $LOG_FILE	
		LINK_FORMAT=$(echo "$mclink" | grep -E "^http://|^https://")
		if [ -z "$LINK_FORMAT" ]; then
			echo_date "订阅地址错误！检测到你输入的订阅地址并不是标准网址格式！"
			sleep 2
			echo_date "退出订阅程序,请手动刷新退出" >> $LOG_FILE
			unset_lock
			echo BBABBBBC >> $LOG_FILE
			exit 1
		else
			echo_date "订阅地址是：$LINK_FORMAT"
			echo_date "开始更新在线订阅列表..." 
			echo_date "开始下载订阅链接到本地临时文件，请稍等..."
			#rm -rf /tmp/clash_subscribe_file* >/dev/null 2>&1
			
			echo_date "使用常规网络下载,写入临时文件/tmp/clash_subscribe_file.txt..."
			curl -4sSk --connect-timeout 8 $mclink > /tmp/clash_subscribe_file1.txt
			cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt

			sleep 1s
			#虽然为0但是还是要检测下是否下载到正确的内容
			echo_date "检查下载是否正确"
			if [ "$?" == "0" ]; then
				#订阅地址有跳转
				local blank=$(cat /tmp/clash_subscribe_file.txt | grep -E " |Redirecting|301")
				if [ -n "$blank" ]; then
					echo_date "订阅链接可能有跳转，尝试更换wget进行下载..."
					rm /tmp/clash_subscribe_file.txt
					if [ -n $(echo $mclink | grep -E "^https") ]; then
						wget --no-check-certificate --timeout=15 -qO /tmp/clash_subscribe_file1.txt $mclink
						#curl --connect-timeout 10 -s $mclink > /tmp/clash_subscribe_file1.txt
						cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt
					else
						wget --timeout=15 -qO /tmp/clash_subscribe_file1.txt $mclink
						cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt
					fi
				fi
				#下载为空...
				if [ -z "$(cat /tmp/clash_subscribe_file.txt)" ]; then
					echo_date "下载内容为空..."
					echo BBABBBBC >> $LOG_FILE
					exit 1
				fi
				#产品信息错误
				local wrong1=$(cat /tmp/clash_subscribe_file.txt | grep "{")
				local wrong2=$(cat /tmp/clash_subscribe_file.txt | grep "<")
				if [ -n "$wrong1" -o -n "$wrong2" ]; then
					echo_date "下载的文件非常规订阅文件,无法转换成配置文件" >> $LOG_FILE
					echo BBABBBBC >> $LOG_FILE
					exit 1
				fi
			else
				echo_date "使用curl下载订阅失败，尝试更换wget进行下载..."
				rm /tmp/clash_subscribe_file.txt
				if [ -n $(echo $mclink | grep -E "^https") ]; then
					wget --no-check-certificate --timeout=15 -qO /tmp/clash_subscribe_file1.txt $mclink
					cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt
				else
					wget -qO /tmp/clash_subscribe_file1.txt $mclink
					cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt
				fi

				if [ "$?" == "0" ]; then
					#下载为空...
					if [ -z "$(cat /tmp/clash_subscribe_file.txt)" ]; then
						echo_date "下载内容为空..."
						echo BBABBBBC >> $LOG_FILE
						exit 1
					fi
					#产品信息错误
					local wrong1=$(cat /tmp/clash_subscribe_file.txt | grep "{")
					local wrong2=$(cat /tmp/clash_subscribe_file.txt | grep "<")
					if [ -n "$wrong1" -o -n "$wrong2" ]; then
						echo_date "下载的文件非常规订阅文件,无法转换成配置文件" >> $LOG_FILE
						echo BBABBBBC >> $LOG_FILE
						exit 1
					fi
				else
					echo BBABBBBC >> $LOG_FILE
					exit 1
				fi
			fi	
		fi
	done
		if [ "$?" == "0" ]; then
			echo_date "下载订阅成功..."
			echo_date "开始解析节点信息..."
			echo_date "下载订阅成功开始解析节点信息" >> $LOG_FILE
			#clash_subscribe_file是一个base64加密过的数据
			decode_url_link $(cat /tmp/clash_subscribe_file.txt) > /tmp/clash_subscribe_file_temp1.txt
			# 检测 ss ssr vmess
			NODE_FORMAT1=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -E "^ss://")
			NODE_FORMAT2=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -E "^ssr://")
			NODE_FORMAT3=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -E "^vmess://")
			NODE_FORMAT4=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -E "^trojan://")
			echo_date "即将创建yaml格式文件，当前使用规则类型为:$merlinclash_localrulesel,版本为:$rule_version" >> $LOG_FILE
			#ss节点
			if [ -n "$NODE_FORMAT1" ]; then
				# 每次更新后进行初始化
				urllinks=""
				link=""
				decode_link=""
				nnum=0
				NODE_NU0=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -c "ss://")
				echo_date "检测到ss节点格式，共计$NODE_NU0个节点..."
				#urllinks为去掉ss://头的节点格式
				#例子:YWVzLTEyOC1nY20jlueE1P@shcn21.qi.xyz:152/?plugin=obfs-local;obfs=tls;obfs-host=bebca9215.wns.windows.com&group=RGxlciBDbG91ZA#香港高级 CN1 01
				urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep -E "^ss://" | sed 's/ss:\/\///g')
				#echo_date $urllinks
				[ -z "$urllinks" ] && continue
				for link in $urllinks
				#对节点信息进行拆分			
				do
					if [ -n "$(echo -n "$link" | grep "#")" ];then
						#去掉ss://头部跟#后的标题
						# new_sslink=YWVzLTEyOC1nY206VlhQaXBpMjlueE1P@shcn21.qiangdong.xyz:152/?plugin=obfs-local%3Bobfs%3Dtls%3Bobfs-host%3Dbebca9215.wns.windows.com&group=RGxlciBDbG91ZA
						new_sslink=$(echo -n "$link" | awk -F'#' '{print $1}' | sed 's/ss:\/\///g')	
						#echo_date "new_sslink=$new_sslink"
						# 有些链接被 url 编码过，所以要先 url 解码
						# link=ss://YWVzLTEyOC1nY206VlhQaXBpMjlueE1P@shcn21.qiangdong.xyz:152/?plugin=obfs-local;obfs=tls;obfs-host=bebca9215.wns.windows.com&group=RGxlciBDbG91ZA#香港高级 CN2 01
						link=$(printf $(echo -n $link | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g'))
						#echo_date "link=$link"
						#new_sslink=YWVzLTEyOC1nY206VlhQaXBpMjlueE1P@shcn21.qiangdong.xyz:152/?plugin=obfs-local;obfs=tls;obfs-host=bebca9215.wns.windows.com&group=RGxlciBDbG91ZA
						new_sslink=$(printf $(echo -n $new_sslink | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g'))
						#echo_date "new_sslink=$new_sslink"
						# 因为订阅的  里面有 \r\n ，所以需要先去除，否则就炸了，只能卸载重装,取出标题
						#remarks=香港高级CN201
						remarks=$(echo -n "$link" | awk -F'#' '{print $2}' | sed 's/[\r\n ]//g')	
						#echo_date "remarks=$remarks"
					else
						new_sslink=$(echo -n "$link" | sed 's/s:\/\///g')
						remarks="ss_node_$nnum"
					fi
					# 链接中有 ? 开始的参数,参数有意义，后面处理
					#new_ss_link=$(echo -n "$new_sslink" | awk -F'?' '{print $1}')	
					get_ss_config $new_sslink 
					[ "$?" == "0" ] && add_ss_servers || echo_date "检测到一个错误ss节点，已经跳过！"
					let nnum++
				done
				echo_date "ss节点转换完毕"
			fi
			#ssr节点
			if [ -n "$NODE_FORMAT2" ]; then
				# 每次更新后进行初始化
				urllinks=""
				link=""
				decode_link=""
				nnum=0
				NODE_NU1=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -c "ssr://")
				echo_date "检测到ssr节点格式，共计$NODE_NU1个节点..."
				# 判断格式
				maxnum=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep "MAX=" | awk -F"=" '{print $2}' | grep -Eo "[0-9]+")
				if [ -n "$maxnum" ]; then
					# 如果机场订阅解析后有MAX=xx字段存在，那么随机选取xx个节点，并去掉ssr://头部标识
					urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | sed '/MAX=/d' | shuf -n $maxnum | sed 's/ssr:\/\///g')
				else
					# 生成全部节点的节点信息，并去掉ssr://头部标识
					#urllinks=$(decode_url_link $(cat /tmp/ssr_subscribe_file.txt) | sed 's/ssr:\/\///g') 20200526
					urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep -E "^ssr://" | sed 's/ssr:\/\///g')
				fi
				[ -z "$urllinks" ] && continue
				# 针对每个节点进行解码：decode_link，解析：get_ssr_node_info，添加/修改：update_ssr_nodes
				for link in $urllinks
				do
					decode_link=$(decode_url_link $link)
					get_ssr_node_info $decode_link
					[ "$?" == "0" ] && add_ssr_nodes || echo_date "检测到一个错误ssr节点，已经跳过！"
					let nnum++
				done	
				echo_date "ssr节点转换完毕"		
			fi
			#v2ray节点
			if [ -n "$NODE_FORMAT3" ]; then
				# 每次更新后进行初始化
				urllinks=""
				link=""
				decode_link=""
				nnum=0
				NODE_NU2=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -Ec "vmess://")
					echo_date "检测到vmess节点格式，共计$NODE_NU2个节点..."
					echo_date "开始解析vmess节点格式"
					#urllinks=$(decode_url_link $(cat /tmp/ssr_subscribe_file.txt) | sed 's/vmess:\/\///g')
					urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep -E "^vmess://" | sed 's/vmess:\/\///g')
					[ -z "$urllinks" ] && continue
					for link in $urllinks
					do
						decode_link=$(decode_url_link $link)
						decode_link=$(echo $decode_link | jq -c .)
						if [ -n "$decode_link" ]; then
							get_v2ray_remote_config "$decode_link"
							[ "$?" == "0" ] && add_v2ray_servers || echo_date "检测到一个错误节点，已经跳过！"
						else
							echo_date "解析失败！！！"
						fi
						let nnum++
					done
					echo_date "v2ray节点转换完毕"	
			fi
			#trojan节点
			if [ -n "$NODE_FORMAT4" ];then
				# 每次更新后进行初始化
				urllinks=""
				link=""
				decode_link=""
				nnum=0
				# 统计trojan节点数量
				NODE_NU3=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -c "trojan://")
				echo_date "检测到 Trojan 节点格式，共计 $NODE_NU3 个节点..."
				#urllinks=$(decode_url_link $(cat /tmp/ssr_subscribe_file.txt) | sed 's/trojan:\/\///g')
				urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep -E "^trojan://" | sed 's/trojan:\/\///g')
				[ -z "$urllinks" ] && continue
				for link in $urllinks
				#对节点信息进行拆分			
				do
					if [ -n "$(echo -n "$link" | grep "#")" ];then
						new_sslink=$(echo -n "$link" | awk -F'#' '{print $1}' | sed 's/trojan:\/\///g')		
						# 有些链接被 url 编码过，所以要先 url 解码
						link=$(printf $(echo -n $link | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g'))
						# 因为订阅的 trojan 里面有 \r\n ，所以需要先去除，否则就炸了，只能卸载重装
						remarks=$(echo -n "$link" | awk -F'#' '{print $2}' | sed 's/[\r\n ]//g')	
						
					else
						new_sslink=$(echo -n "$link" | sed 's/trojan:\/\///g')
						remarks="trojan_node_$nnum"
					fi
					# 链接中有 ? 开始的参数，去掉这些参数
					new_trojan_link=$(echo -n "$new_sslink" | awk -F'?' '{print $1}')	
					get_trojan_config $new_trojan_link
					[ "$?" == "0" ] && add_trojan_servers || echo_date "检测到一个错误节点，已经跳过！"
					let nnum++
				done
				echo_date "trojan节点转换完毕"	
			fi
			echo_date "节点全部转换完毕"
			write_yaml
		fi

}

get_oneline_rule_regular_update(){
	updateflag="get_oneline_rule_regular_update"
	merlinc_link=$2
	#20200806 新增多链接转换成一个
	mclinks=$(echo $merlinc_link | sed 's/\\n/ /g')	
	upname=$1
	dbus set merlinclash_localrulesel=$3
	dbus set merlinclash_uploadrename2=$upname
	dbus set merlinclash_links2=$2
	echo_date "$merlinclash_localrulesel"
	echo_date "$upname"
	# ss订阅	
	echo_date "开始更新在线订阅列表..." 
	echo_date "开始下载订阅链接到本地临时文件，请稍等..."
	rm -rf /tmp/clash_subscribe_file* >/dev/null 2>&1
	for mclink in $mclinks; do
		echo_date "使用常规网络下载,写入临时文件/tmp/clash_subscribe_file.txt..."
		curl -4sSk --connect-timeout 8 $mclink > /tmp/clash_subscribe_file1.txt
		cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt

		sleep 1s
		#虽然为0但是还是要检测下是否下载到正确的内容
		echo_date "检查下载是否正确"
		if [ "$?" == "0" ]; then
			#订阅地址有跳转
			local blank=$(cat /tmp/clash_subscribe_file.txt | grep -E " |Redirecting|301")
			if [ -n "$blank" ]; then
				echo_date "订阅链接可能有跳转，尝试更换wget进行下载..."
				rm /tmp/clash_subscribe_file.txt
				if [ -n $(echo $mclink | grep -E "^https") ]; then
					wget --no-check-certificate --timeout=15 -qO /tmp/clash_subscribe_file1.txt $mclink
					cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt
				else
					wget -qO /tmp/clash_subscribe_file1.txt $mclink
					cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt
				fi
			fi
			#下载为空...
			if [ -z "$(cat /tmp/clash_subscribe_file.txt)" ]; then
				echo_date "下载内容为空..."
				echo BBABBBBC >> $LOG_FILE
				exit 1
			fi
			#产品信息错误
			local wrong1=$(cat /tmp/clash_subscribe_file.txt | grep "{")
			local wrong2=$(cat /tmp/clash_subscribe_file.txt | grep "<")
			if [ -n "$wrong1" -o -n "$wrong2" ]; then
				echo_date "下载的文件非常规订阅文件,无法转换成配置文件" >> $LOG_FILE
				echo BBABBBBC >> $LOG_FILE
				exit 1
			fi
		else
			echo_date "使用curl下载订阅失败，尝试更换wget进行下载..."
			rm /tmp/clash_subscribe_file.txt
			if [ -n $(echo $mclink | grep -E "^https") ]; then
				wget --no-check-certificate --timeout=15 -qO /tmp/clash_subscribe_file1.txt $mclink
				cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt
			else
				wget -qO /tmp/clash_subscribe_file1.txt $mclink
				cat /tmp/clash_subscribe_file1.txt >> /tmp/clash_subscribe_file.txt
			fi
				if [ "$?" == "0" ]; then
				#下载为空...
				if [ -z "$(cat /tmp/clash_subscribe_file.txt)" ]; then
					echo_date "下载内容为空..."
					echo BBABBBBC >> $LOG_FILE
					exit 1
				fi
				#产品信息错误
				local wrong1=$(cat /tmp/clash_subscribe_file.txt | grep "{")
				local wrong2=$(cat /tmp/clash_subscribe_file.txt | grep "<")
				if [ -n "$wrong1" -o -n "$wrong2" ]; then
					echo_date "下载的文件非常规订阅文件,无法转换成配置文件" >> $LOG_FILE
					echo BBABBBBC >> $LOG_FILE
					exit 1
				fi
			else
				echo BBABBBBC >> $LOG_FILE
				exit 1
			fi
		fi
	done	
	if [ "$?" == "0" ]; then
		echo_date "下载订阅成功..."
		echo_date "开始解析节点信息..."
		echo_date "下载订阅成功开始解析节点信息" >> $LOG_FILE
		#clash_subscribe_file是一个base64加密过的数据
		decode_url_link $(cat /tmp/clash_subscribe_file.txt) > /tmp/clash_subscribe_file_temp1.txt
		# 检测 ss ssr vmess
		NODE_FORMAT1=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -E "^ss://")
		NODE_FORMAT2=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -E "^ssr://")
		NODE_FORMAT3=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -E "^vmess://")
		NODE_FORMAT4=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -E "^trojan://")
		echo_date "即将创建yaml格式文件，当前使用规则类型为:$merlinclash_localrulesel,版本为:$rule_version" >> $LOG_FILE
		#ss节点
		if [ -n "$NODE_FORMAT1" ]; then
			# 每次更新后进行初始化
			urllinks=""
			link=""
			decode_link=""
			nnum=0
			NODE_NU0=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -c "ss://")
			echo_date "检测到ss节点格式，共计$NODE_NU0个节点..."
			#urllinks为去掉ss://头的节点格式
			#例子:YWVzLTEyOC1nY20jlueE1P@shcn21.qi.xyz:152/?plugin=obfs-local;obfs=tls;obfs-host=bebca9215.wns.windows.com&group=RGxlciBDbG91ZA#香港高级 CN1 01
			urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep -E "^ss://" | sed 's/ss:\/\///g')
			#echo_date $urllinks
			[ -z "$urllinks" ] && continue
			for link in $urllinks
			#对节点信息进行拆分			
			do
				if [ -n "$(echo -n "$link" | grep "#")" ];then
					#去掉ss://头部跟#后的标题
					# new_sslink=YWVzLTEyOC1nY206VlhQaXBpMjlueE1P@shcn21.qiangdong.xyz:152/?plugin=obfs-local%3Bobfs%3Dtls%3Bobfs-host%3Dbebca9215.wns.windows.com&group=RGxlciBDbG91ZA
					new_sslink=$(echo -n "$link" | awk -F'#' '{print $1}' | sed 's/ss:\/\///g')	
					#echo_date "new_sslink=$new_sslink"
					# 有些链接被 url 编码过，所以要先 url 解码
					# link=ss://YWVzLTEyOC1nY206VlhQaXBpMjlueE1P@shcn21.qiangdong.xyz:152/?plugin=obfs-local;obfs=tls;obfs-host=bebca9215.wns.windows.com&group=RGxlciBDbG91ZA#香港高级 CN2 01
					link=$(printf $(echo -n $link | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g'))
					#echo_date "link=$link"
					#new_sslink=YWVzLTEyOC1nY206VlhQaXBpMjlueE1P@shcn21.qiangdong.xyz:152/?plugin=obfs-local;obfs=tls;obfs-host=bebca9215.wns.windows.com&group=RGxlciBDbG91ZA
					new_sslink=$(printf $(echo -n $new_sslink | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g'))
					#echo_date "new_sslink=$new_sslink"
					# 因为订阅的  里面有 \r\n ，所以需要先去除，否则就炸了，只能卸载重装,取出标题
					#remarks=香港高级CN201
					remarks=$(echo -n "$link" | awk -F'#' '{print $2}' | sed 's/[\r\n ]//g')	
					#echo_date "remarks=$remarks"
				else
					new_sslink=$(echo -n "$link" | sed 's/s:\/\///g')
					remarks="ss_node_$nnum"
				fi
				# 链接中有 ? 开始的参数,参数有意义，后面处理
				#new_ss_link=$(echo -n "$new_sslink" | awk -F'?' '{print $1}')	
				get_ss_config $new_sslink 
				[ "$?" == "0" ] && add_ss_servers || echo_date "检测到一个错误ss节点，已经跳过！"
				let nnum++
			done
			echo_date "ss节点转换完毕"
		fi
		#ssr节点
		if [ -n "$NODE_FORMAT2" ]; then
			# 每次更新后进行初始化
			urllinks=""
			link=""
			decode_link=""
			nnum=0
			NODE_NU1=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -c "ssr://")
			echo_date "检测到ssr节点格式，共计$NODE_NU1个节点..."
			# 判断格式
			maxnum=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep "MAX=" | awk -F"=" '{print $2}' | grep -Eo "[0-9]+")
			if [ -n "$maxnum" ]; then
				# 如果机场订阅解析后有MAX=xx字段存在，那么随机选取xx个节点，并去掉ssr://头部标识
				urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | sed '/MAX=/d' | shuf -n $maxnum | sed 's/ssr:\/\///g')
			else
				# 生成全部节点的节点信息，并去掉ssr://头部标识
				#urllinks=$(decode_url_link $(cat /tmp/ssr_subscribe_file.txt) | sed 's/ssr:\/\///g') 20200526
				urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep -E "^ssr://" | sed 's/ssr:\/\///g')
			fi
			[ -z "$urllinks" ] && continue
			# 针对每个节点进行解码：decode_link，解析：get_ssr_node_info，添加/修改：update_ssr_nodes
			for link in $urllinks
			do
				decode_link=$(decode_url_link $link)
				get_ssr_node_info $decode_link
				[ "$?" == "0" ] && add_ssr_nodes || echo_date "检测到一个错误ssr节点，已经跳过！"
				let nnum++
			done	
			echo_date "ssr节点转换完毕"		
		fi
		#v2ray节点
		if [ -n "$NODE_FORMAT3" ]; then
			# 每次更新后进行初始化
			urllinks=""
			link=""
			decode_link=""
			nnum=0
			NODE_NU2=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -Ec "vmess://")
			echo_date "检测到vmess节点格式，共计$NODE_NU2个节点..."
			echo_date "开始解析vmess节点格式"
			#urllinks=$(decode_url_link $(cat /tmp/ssr_subscribe_file.txt) | sed 's/vmess:\/\///g')
			urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep -E "^vmess://" | sed 's/vmess:\/\///g')
			[ -z "$urllinks" ] && continue
			for link in $urllinks
			do
				decode_link=$(decode_url_link $link)
				decode_link=$(echo $decode_link | jq -c .)
					if [ -n "$decode_link" ]; then
						get_v2ray_remote_config "$decode_link"
						[ "$?" == "0" ] && add_v2ray_servers || echo_date "检测到一个错误节点，已经跳过！"
					else
						echo_date "解析失败！！！"
					fi
					let nnum++
				done
				echo_date "v2ray节点转换完毕"	
		fi
		#trojan节点
		if [ -n "$NODE_FORMAT4" ];then
			# 每次更新后进行初始化
			urllinks=""
			link=""
			decode_link=""
			nnum=0
			# 统计trojan节点数量
			NODE_NU3=$(cat /tmp/clash_subscribe_file_temp1.txt | grep -c "trojan://")
			echo_date "检测到 Trojan 节点格式，共计 $NODE_NU3 个节点..."
			#urllinks=$(decode_url_link $(cat /tmp/ssr_subscribe_file.txt) | sed 's/trojan:\/\///g')
			urllinks=$(decode_url_link $(cat /tmp/clash_subscribe_file.txt) | grep -E "^trojan://" | sed 's/trojan:\/\///g')
			[ -z "$urllinks" ] && continue
			for link in $urllinks
			#对节点信息进行拆分			
			do
				if [ -n "$(echo -n "$link" | grep "#")" ];then
					new_sslink=$(echo -n "$link" | awk -F'#' '{print $1}' | sed 's/trojan:\/\///g')		
					# 有些链接被 url 编码过，所以要先 url 解码
					link=$(printf $(echo -n $link | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g'))
					# 因为订阅的 trojan 里面有 \r\n ，所以需要先去除，否则就炸了，只能卸载重装
					remarks=$(echo -n "$link" | awk -F'#' '{print $2}' | sed 's/[\r\n ]//g')	
					
				else
					new_sslink=$(echo -n "$link" | sed 's/trojan:\/\///g')
					remarks="trojan_node_$nnum"
				fi
				# 链接中有 ? 开始的参数，去掉这些参数
				new_trojan_link=$(echo -n "$new_sslink" | awk -F'?' '{print $1}')	
				get_trojan_config $new_trojan_link
				[ "$?" == "0" ] && add_trojan_servers || echo_date "检测到一个错误节点，已经跳过！"
				let nnum++
				done
				echo_date "trojan节点转换完毕"	
		fi
		echo_date "节点全部转换完毕"
		write_yaml
	fi


}

add_trojan_servers(){
	#节点名去空格，免得出错
	remarks=$(echo $remarks | sed 's/ //g')
	echo_date "$num ：转换 trojan 节点：$remarks"
	#echo_date $num
	#echo_date $num $server
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].name "$remarks"
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].type "trojan"
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].server $server
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].port $server_port
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].password $password
	sed -i "\$i\ \ \- { name: "\"$remarks\"", type: trojan, server: "\"$server\"", port: "$server_port", password: "\"$password\"", sni: "\"$server\"" }" /tmp/upload/proxies.yaml
	
	let num++	
}

get_trojan_config(){
	decode_link=$1
	server=$(echo "$decode_link" |awk -F':' '{print $1}'|awk -F'@' '{print $2}')
	server_port=$(echo "$decode_link" |awk -F':' '{print $2}')
	password=$(echo "$decode_link" |awk -F':' '{print $1}'|awk -F'@' '{print $1}')
	#password=`echo $password|base64_encode`

	[ -n "$server" ] && return 0 || return 1
}

add_v2ray_servers(){
	#节点名去空格，免得出错
	v2ray_ps=$(echo $v2ray_ps | sed 's/ //g')
	echo_date "$num ：转换 v2ray 节点：$v2ray_ps"
	#echo_date $num
	#echo_date $num $v2ray_add
	#20200724改用sed
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].name "$v2ray_ps"
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].type "vmess"
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].server $v2ray_add
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].port $v2ray_port
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].uuid $v2ray_id
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].alterId $v2ray_aid
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].cipher "auto"
	sed -i "\$i\ \ \- { name: "\"$v2ray_ps\"", type: vmess, server: "\"$v2ray_add\"", port: "$v2ray_port", uuid: "\"$v2ray_id\"", alterId: "\"$v2ray_aid\"", cipher: "\"auto\"", tls: "$v2ray_tls", network: "\"$v2ray_net\"", ws-path: "\"$v2ray_path\"", ws-headers: {Host: "\"$v2ray_host\""}}" /tmp/upload/proxies.yaml
	let num++

}

get_v2ray_remote_config(){
	decode_link="$1"
	v2ray_v=$(echo "$decode_link" | jq -r .v)
	v2ray_ps=$(echo "$decode_link" | jq -r .ps | sed 's/[ \t]*//g')
	v2ray_add=$(echo "$decode_link" | jq -r .add | sed 's/[ \t]*//g')
	v2ray_port=$(echo "$decode_link" | jq -r .port | sed 's/[ \t]*//g')
	v2ray_id=$(echo "$decode_link" | jq -r .id | sed 's/[ \t]*//g')
	v2ray_aid=$(echo "$decode_link" | jq -r .aid | sed 's/[ \t]*//g')
	v2ray_net=$(echo "$decode_link" | jq -r .net)
	v2ray_type=$(echo "$decode_link" | jq -r .type)
	v2ray_tls_tmp=$(echo "$decode_link" | jq -r .tls)
	[ "$v2ray_tls_tmp"x == "tls"x ] && v2ray_tls="true" || v2ray_tls="false"
	
	if [ "$v2ray_v" == "2" ]; then
		# "new format"
		v2ray_path=$(echo "$decode_link" | jq -r .path)
		v2ray_host=$(echo "$decode_link" | jq -r .host)
	else
		# "old format"
		case $v2ray_net in
		tcp)
			v2ray_host=$(echo "$decode_link" | jq -r .host)
			v2ray_path=""
			;;
		kcp)
			v2ray_host=""
			v2ray_path=""
			;;
		ws)
			v2ray_host_tmp=$(echo "$decode_link" | jq -r .host)
			if [ -n "$v2ray_host_tmp" ]; then
				format_ws=$(echo $v2ray_host_tmp | grep -E ";")
				if [ -n "$format_ws" ]; then
					v2ray_host=$(echo $v2ray_host_tmp | cut -d ";" -f1)
					v2ray_path=$(echo $v2ray_host_tmp | cut -d ";" -f1)
				else
					v2ray_host=""
					v2ray_path=$v2ray_host
				fi
			fi
			;;
		h2)
			v2ray_host=""
			v2ray_path=$(echo "$decode_link" | jq -r .path)
			;;
		esac
	fi
	# for debug
	# echo ------------------
	# echo v2ray_v: $v2ray_v
	# echo v2ray_ps: $v2ray_ps
	# echo v2ray_add: $v2ray_add
	# echo v2ray_port: $v2ray_port
	# echo v2ray_id: $v2ray_id
	# echo v2ray_net: $v2ray_net
	# echo v2ray_type: $v2ray_type
	# echo v2ray_host: $v2ray_host
	# echo v2ray_path: $v2ray_path
	# echo v2ray_tls: $v2ray_tls
	# echo ------------------
	
	[ -z "$v2ray_ps" -o -z "$v2ray_add" -o -z "$v2ray_port" -o -z "$v2ray_id" -o -z "$v2ray_aid" -o -z "$v2ray_net" -o -z "$v2ray_type" ] && return 1 || return 0
}

add_ssr_nodes(){
	#节点名去空格，免得出错
	remarks=$(echo $remarks | sed 's/ //g')
	echo_date "$num ：转换 ssr 节点：$remarks"
	#echo_date $num
	#echo_date $num $server
	#20200724改用sed
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].name "$remarks"
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].type "ssr"
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].server $server
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].port $server_port
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].cipher $encrypt_method
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].password $password
	#[ -n "$protocol" ] && yq w -i /tmp/upload/proxies.yaml proxies[$num].protocol $protocol
	#[ -n "$protoparam" ] && yq w -i /tmp/upload/proxies.yaml proxies[$num].protocolparam $protoparam
	#[ -n "$obfs" ] && yq w -i /tmp/upload/proxies.yaml proxies[$num].obfs $obfs
	#[ -n "$obfsparam" ] && yq w -i /tmp/upload/proxies.yaml proxies[$num].obfsparam $obfsparam
	sed -i "\$i\ \ \- { name: "\"$remarks\"", type: ssr, server: "\"$server\"", port: "$server_port", password: "\"$password\"", cipher: "\"$encrypt_method\"", protocol: "\"$protocol\"", protocol-param: "\"$protoparam\"",protocolparam: "\"$protoparam\"", obfs: "\"$obfs\"", obfs-param: "\"$obfsparam\"", obfsparam: "\"$obfsparam\"" }" /tmp/upload/proxies.yaml
	let num++
	#20200724,改用sed插入

}
get_ssr_node_info(){
	decode_link="$1"
	server=$(echo "$decode_link" | awk -F':' '{print $1}' | sed 's/\s//g')
	server_port=$(echo "$decode_link" | awk -F':' '{print $2}')
	protocol=$(echo "$decode_link" | awk -F':' '{print $3}')
	encrypt_method=$(echo "$decode_link" |awk -F':' '{print $4}')
	obfs=$(echo "$decode_link" | awk -F':' '{print $5}' | sed 's/_compatible//g')
	password=$(decode_url_link $(echo "$decode_link" | awk -F':' '{print $6}' | awk -F'/' '{print $1}'))
	#password=$(echo $password | base64_encode | sed 's/\s//g')
	
	obfsparam_temp=$(echo "$decode_link" | awk -F':' '{print $6}' | grep -Eo "obfsparam.+" | sed 's/obfsparam=//g' | awk -F'&' '{print $1}')
	[ -n "$obfsparam_temp" ] && obfsparam=$(decode_url_link $obfsparam_temp) || obfsparam=''
	#if [ -n "$obfsparam_temp" ]; then
	#obfsparam=$(decode_url_link $obfsparam_temp)
	#else
	#	obfsparam="www.microsoft.com"
	#fi
	protoparam_temp=$(echo "$decode_link" | awk -F':' '{print $6}' | grep -Eo "protoparam.+" | sed 's/protoparam=//g' | awk -F'&' '{print $1}')
	[ -n "$protoparam_temp" ] && protoparam=$(decode_url_link $protoparam_temp | sed 's/_compatible//g') || protoparam=''
	
	remarks_temp=$(echo "$decode_link" | awk -F':' '{print $6}' | grep -Eo "remarks.+" | sed 's/remarks=//g' | awk -F'&' '{print $1}')
	
	[ -n "$remarks_temp" ] && remarks=$(decode_url_link $remarks_temp) || remarks="ssr_node_$nnum"
	
	[ -n "$server" ] && return 0 || return 1
	
	# for debug, please keep it here~
	# echo ------------
	# echo group: $group
	# echo remarks: $remarks
	# echo server: $server
	# echo server_port: $server_port
	# echo password: $password
	# echo encrypt_method: $encrypt_method
	# echo protocol: $protocol
	# echo protoparam: $protoparam
	# echo obfs: $obfs
	# echo obfsparam: $obfsparam
	# echo ------------
}

add_ss_servers(){
	#节点名去空格，免得出错
	remarks=$(echo $remarks | sed 's/ //g')
	echo_date "$num ：转换 ss 节点：$remarks"
	#echo_date $num
	#echo_date $num $server
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].name "$remarks"
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].type "ss"
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].server $server
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].port $server_port
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].cipher $encrypt_method
	#yq w -i /tmp/upload/proxies.yaml proxies[$num].password $password
	#20200724改用sed写入
	#格式参考
	##  - {name: 🇭🇰 香港高级 BGP 10, server: 119.39.28.81, port: 152, type: ss, cipher: aes-128-gcm, password: VXPipi29nxMO, plugin: obfs, plugin-opts: {mode: tls, host: 1816e78137.wns.windows.com}, udp: true}
	if [ "$obfs_tmp" == "tls" ]; then
		sed -i "\$i\ \ \- { name: "\"$remarks\"", type: ss, server: "\"$server\"", port: "$server_port", password: "\"$password\"", cipher: "\"$encrypt_method\"", plugin: "obfs", plugin-opts: {mode: "\"$obfs_tmp\"", host: "\"$obfs_host\""}, udp: true}" /tmp/upload/proxies.yaml
	else
		sed -i "\$i\ \ \- { name: "\"$remarks\"", type: ss, server: "\"$server\"", port: "$server_port", password: "\"$password\"", cipher: "\"$encrypt_method\"" }" /tmp/upload/proxies.yaml
	fi
	let num++
}
get_ss_config(){
#+++++++++++++++++++++参考+++++++++++++++++++++++++
#	name: "\U0001F1ED\U0001F1F0 香港高级 BGP 10"
# 	type: ss
#  	server: 119.39.28.81
#  	port: 152
#  	cipher: aes-128-gcm
#  	password: VXPipi29nxMO
#  	udp: true
#  	plugin: obfs
#  	plugin-opts:
#    mode: tls
#    host: 1816e78137.wns.windows.com
#  - {name: 🇭🇰 香港高级 BGP 10, server: 119.39.28.81, port: 152, type: ss, cipher: aes-128-gcm, password: VXPipi29nxMO, plugin: obfs, plugin-opts: {mode: tls, host: 1816e78137.wns.windows.com}, udp: true}
#+++++++++++++++++++++参考+++++++++++++++++++++++++
	decode_link=$1
	server=$(echo "$decode_link" |awk -F'[@:]' '{print $2}')
	server_port=$(echo "$decode_link" |awk -F'[:/?]' '{print $2}')
	#首段的加密方式跟密码进行解码，method_password=aes-128-gcm:VXPipi29nxMO
	method_password=$(echo "$decode_link" |awk -F'[@:]' '{print $1}' | sed 's/-/+/g; s/_/\//g')
	method_password=$(decode_url_link $(echo "$method_password"))
	encrypt_method=$(echo "$method_password" |awk -F':' '{print $1}')
	password=$(echo "$method_password" |awk -F':' '{print $2}')
	#password=$(echo $password | base64_encode)
	#参数获值 plugin=obfs-local;obfs=tls;obfs-host=1816e78137.wns.windows.com&group=RGxlciBDbG91ZA
	plugin=$(echo "$decode_link" |awk -F'?' '{print $2}')
	#去掉无plugin但是有group=造成误取值
	#plugin=obfs-local;obfs=tls;obfs-host=1816e78137.wns.windows.com&
	plugin=$(echo "$plugin" |awk -F'group' '{print $1}')
	if [ -n "$plugin" ];then
		obfs_tmp=$(echo "$plugin" | awk -F'obfs=' '{print $2}' | awk -F';' '{print $1}')
		#obfs_tmp=tls
		case "$obfs_tmp" in
		tls)
			obfs_host=$(echo "$plugin" | awk -F'obfs=' '{print $2}' | awk -F';' '{print $2}' | awk -F'&' '{print $1}' | awk -F'obfs-host=' '{print $2}')
			#obfs_host=1816e78137.wns.windows.com
		;;
		http)
			obfs_host=$(echo "$plugin" | awk -F'obfs=' '{print $2}' | awk -F';' '{print $2}' | awk -F'&' '{print $1}' | awk -F'obfs-host=' '{print $2}')
		;;
		esac
		
	else
		echo_date "weikong"
	fi
	#echo_date $server
	#echo_date $server_port
	#echo_date $encrypt_method
	#echo_date $password
	#echo_date $obfs_tmp
	#echo_date $obfs_host
	[ -n "$server" ] && return 0 || return 1
}
write_yaml(){
	echo_date "开始写入节点名称"
	#test=$(echo $(yq r /tmp/upload/proxies.yaml proxies[*].name))
	#20200724改用工具
	#test=$(grep  "name" /tmp/upload/proxies.yaml | awk -F","  '{print $1}' | awk -F":" '{print $2}' | awk -F "[\"\"]" '{print $2}')
	test=$(grep  "name" /tmp/upload/proxies.yaml | awk -F","  '{print $1}' | awk -F "[\"\"]" '{print $2}')
	for t in $test;
	do 
		str=$str,"\"$t"\"
	done
	proxy=$(echo $str |  awk '{print substr($1,2)}')
	sleep 1s
	if [ "$merlinclash_localrulesel" == "常规规则" ]; then 		
		sed -i "s?url-test, proxies,?url-test, proxies: [$proxy],?g" /tmp/upload/proxy-group.yaml
		sed -i "s?fallback, proxies,?fallback, proxies: [$proxy],?g" /tmp/upload/proxy-group.yaml
		sed -i "s?load-balance, proxies,?load-balance, proxies: [$proxy],?g" /tmp/upload/proxy-group.yaml
		sed -i "s?type: select, proxies}?type: select, proxies: [$proxy]}?g" /tmp/upload/proxy-group.yaml
		echo_date "写入完成,将对文件进行合并"
	#yq m -x -i /tmp/upload/proxies.yaml /tmp/upload/proxy-group.yaml
		sed -i '$a' /tmp/upload/proxies.yaml
		cat /tmp/upload/proxy-group.yaml >> /tmp/upload/proxies.yaml
		sed -i '$a' /tmp/upload/proxies.yaml
		cat $head_tmp >> /tmp/upload/proxies.yaml
		echo_date "标准头文件合并完毕" >> $LOG_FILE
		#对external-controller赋值
		#yq w -i $yaml_tmp external-controller $lan_ip:9990
		sed -i "s/192.168.2.1:9990/$lan_ip:9990/g" /tmp/upload/proxies.yaml

		#写入hosts
		#yq w -i $yaml_tmp 'hosts.[router.asus.com]' $lan_ip
		sed -i '$a hosts:' /tmp/upload/proxies.yaml
		sed -i '$a \ \ router.asus.com: '"$lan_ip"'' /tmp/upload/proxies.yaml
	fi

	if [ "$merlinclash_localrulesel" == "游戏规则" ]; then 
		sed -i "s/type: select, proxies}/type: select, proxies: [$proxy]}/g" /tmp/upload/proxy-group-game.yaml
		echo_date "写入完成,将对文件进行合并"
		cat /tmp/upload/proxy-group-game.yaml >> /tmp/upload/proxies.yaml
	fi
	echo_date "合并完毕"
	rename_yaml
}
rename_yaml(){
	upname_tmp=$merlinclash_uploadrename2
	time=$(date "+%Y%m%d-%H%M%S")
	newname=$(echo $time | awk -F'-' '{print $2}')
	if [ -n "$upname_tmp" ]; then
		upname=$upname_tmp.yaml
	else
		upname=$newname.yaml
	fi
	if [ "$merlinclash_localrulesel" == "常规规则" ]; then 
		upname=local_$upname
	fi
	if [ "$merlinclash_localrulesel" == "游戏规则" ]; then 
		upname=game_$upname
	fi
	echo_date "文件重命名后复制到/koolshare/merlinclash/yaml_bak/" >> $LOG_FILE
	echo_date "以及/koolshare/merlinclash/yaml_use/" >> $LOG_FILE
	cp -rf /tmp/upload/proxies.yaml /koolshare/merlinclash/yaml_bak/$upname
	cp -rf /tmp/upload/proxies.yaml /koolshare/merlinclash/yaml_use/$upname
	#清理残留
	rm -rf /tmp/upload/*.yaml
	#生成新的txt文件

	rm -rf /koolshare/merlinclash/yaml_bak/yamls.txt
	echo_date "重新创建yaml文件列表" >> $LOG_FILE
	#find $fp  -name "*.yaml" |sed 's#.*/##' >> $fp/yamls.txt
	find /koolshare/merlinclash/yaml_bak  -name "*.yaml" |sed 's#.*/##' |sed '/^$/d' | awk -F'.' '{print $1}' >> /koolshare/merlinclash/yaml_bak/yamls.txt
	#创建软链接
	ln -s /koolshare/merlinclash/yaml_bak/yamls.txt /tmp/upload/yamls.txt
	
	#20200803写入字典
	write_dictionary
	#
	echo_date "订阅处理完毕，请刷新页面查看下拉框是否存在配置名"

}

write_dictionary(){
	if [ -f "$dictionary" ]; then
		name_tmp=$(cat $dictionary | grep -w -n "$upname" | awk -F ":" '{print $1}')
		#定位配置名行数，存在，则覆写；不存在，则新增 -w全字符匹配
		if [ -n "$name_tmp" ]; then
			if [ "$updateflag" == "get_oneline_rule_now" ]; then
				echo_date "【常规订阅】配置名存在，覆写" >> $LOG_FILE
				sed -i "$name_tmp d" $dictionary
				echo \"name\":\"$upname\",\"link\":\"$merlinclash_links2\",\"type\":\"$subscription_type\",\"use\":\"0\",\"ruletype\":\"$merlinclash_localrulesel\" >> $dictionary
				#sed -i "$name_tmp i \"name\":\"$upname\",\"link\":\"$merlinclash_links2\",\"type\":\"$subscription_type\",\"use\":\"0\",\"ruletype\":\"$merlinclash_localrulesel\" " $dictionary
				#sed -i "s?\"name\":\"$upname\",*$""?\"name\":\"$upname\",\"link\":\"$merlinclash_links2\",\"type\":\"$subscription_type\",\"use\":\"0\",\"ruletype\":\"$merlinclash_localrulesel\"?g" $dictionary
			fi
		else
			#新增
			echo_date "配置名不存在，新增" >> $LOG_FILE
			echo \"name\":\"$upname\",\"link\":\"$merlinclash_links2\",\"type\":\"$subscription_type\",\"use\":\"0\",\"ruletype\":\"$merlinclash_localrulesel\" >> $dictionary
		fi
	else
		#为初次订阅，直接写入
		echo_date "初次订阅，直接写入" >> $LOG_FILE
		echo \"name\":\"$upname\",\"link\":\"$merlinclash_links2\",\"type\":\"$subscription_type\",\"use\":\"0\",\"ruletype\":\"$merlinclash_localrulesel\" >> $dictionary
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
17)
	set_lock
	echo "" > $LOG_FILE
	http_response "$1"
	echo_date "常规订阅处理" >> $LOG_FILE
	get_oneline_rule_now >> $LOG_FILE

	echo BBABBBBC >> $LOG_FILE
	unset_lock
	;;
2)
	echo_date "定时订阅处理" >> $LOG_FILE

	get_oneline_rule_regular_update "$1" "$3" "$4" >> $LOG_FILE

	echo BBABBBBC >> $LOG_FILE
esac

