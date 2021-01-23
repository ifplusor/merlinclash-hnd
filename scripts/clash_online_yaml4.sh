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
subscription_type="4"
dictionary=/koolshare/merlinclash/yaml_bak/subscription.txt
updateflag=""
mcflag=$merlinclash_flag


get_acl4ssrsel_name() {
	case "$1" in
		MC_Common)
			echo "MerlinClash常规规则"
		;;
		MC_Area_Fallback)
			echo "MerlinClash分区域故障转移"
		;;
		MC_Area_Urltest)
			echo "MerlinClash分区域自动测速"
		;;
		MC_Area_NoAuto)
			echo "MerlinClash分区域无自动测速"
		;;
		MC_Area_Media)
			echo "MerlinClash媒体与分区域自动测速"
		;;
		MC_Area_Media_NoAuto)
			echo "MerlinClash媒体与分区域无自动测速"
		;;
		Online)
			echo "Online默认版"
		;;
		AdblockPlus)
			echo "AdblockPlus更多去广告"
		;;
		NoAuto)
			echo "NoAuto无自动测速"
		;;
		NoReject)
			echo "NoReject无广告拦截"
		;;
		Mini)
			echo "Mini精简版"
		;;
		Mini_AdblockPlus)
			echo "精简版更多去广告"
		;;
		Mini_NoAuto)
			echo "精简版无自动测速"
		;;
		Mini_Fallback)
			echo "精简版带故障转移"
		;;
		Mini_MultiMode)
			echo "精简版自动测速故障转移负载均衡"
		;;
		Full)
			echo "Full全分组"
		;;
		Full_NoAuto)
			echo "Full无自动测速"
		;;
		Full_AdblockPlus)
			echo "Full更多去广告"
		;;
		Full_Netflix)
			echo "Full奈飞全量"
		;;
	esac
}

start_online_update_hnd(){
	clashtarget=$merlinclash_clashtarget
	acl4ssrsel=$merlinclash_acl4ssrsel
	emoji=$merlinclash_subconverter_emoji
	udp=$merlinclash_subconverter_udp
	appendtype=$merlinclash_subconverter_append_type
	sort=$merlinclash_subconverter_sort
	fnd=$merlinclash_subconverter_fdn
	scv=$merlinclash_subconverter_scv
	tfo=$merlinclash_subconverter_tfo
	include=$merlinclash_subconverter_include
	exclude=$merlinclash_subconverter_exclude
	updateflag="start_online_update"
	if [ "$emoji" == "1" ]; then
		emoji="true"
	else
		emoji="false"
	fi
	if [ "$udp" == "1" ]; then
		udp="true"
	else
		udp="false"
	fi
	if [ "$appendtype" == "1" ]; then
		appendtype="true"
	else
		appendtype="false"
	fi
	if [ "$sort" == "1" ]; then
		sort="true"
	else
		sort="false"
	fi
	if [ "$fnd" == "1" ]; then
		fnd="true"
	else
		fnd="false"
	fi
	if [ "$scv" == "1" ]; then
		scv="true"
	else
		scv="false"
	fi
	if [ "$tfo" == "1" ]; then
		tfo="true"
	else
		tfo="false"
	fi
	#echo_date "$scv | $tfo " >> $LOG_FILE
	#merlinc_link=$merlinclash_links3
	#20200807处理%0A替换成%7C，换行替换成|
	merlinc_link=$(echo $merlinclash_links3 | sed 's/%0A/%7C/g')
		upname_tmp="$merlinclash_uploadrename4"
		#echo_date "订阅文件重命名为：$upname_tmp" >> $LOG_FILE
		time=$(date "+%Y%m%d-%H%M%S")
		newname=$(echo $time | awk -F'-' '{print $2}')
		echo_date "配置名是：$upname_tmp" >> $LOG_FILE
		echo_date "订阅规则类型是：$(get_acl4ssrsel_name $acl4ssrsel)" >> $LOG_FILE
		echo_date "subconverter进程：$(pidof subconverter)" >> $LOG_FILE
		echo_date "即将开始转换，需要一定时间，请等候处理" >> $LOG_FILE
		sleep 3s
		case $acl4ssrsel in
		MC_Common)
			_name="MCC_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		MC_Area_Fallback)
			_name="MAF_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		MC_Area_Urltest)
			_name="MAU_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Urltest.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;	
		MC_Area_NoAuto)
			_name="MAN_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;	
		MC_Area_Media)
			_name="MAM_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Media.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;	
		MC_Area_Media_NoAuto)
			_name="MAMN_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Media_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		Online)
			_name="OL_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online.ini"			
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		AdblockPlus)
			_name="AP_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_AdblockPlus.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		NoAuto)
			_name="NA_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_NoAuto.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		NoReject)
			_name="NR_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_NoReject.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoReject.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Mini)
			_name="Mini_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Mini_AdblockPlus)
			_name="MAP_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_AdblockPlus.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Mini_NoAuto)
			_name="MNA_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_NoAuto.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Mini_Fallback)
			_name="MF_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_Fallback.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Mini_MultiMode)
			_name="MMM_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_MultiMode.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_MultiMode.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Full)
			_name="Full_"
			#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Full_NoAuto)
			_name="FNA_"
			#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full_NoAuto.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Full_AdblockPlus)
			_name="FAP_"
			#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full_AdblockPlus.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Full_Netflix)
			_name="FNX_"
			#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full_Netflix.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_Netflix.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		esac
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

start_dc_online_update_hnd(){
	clashtarget=$merlinclash_dc_clashtarget
	acl4ssrsel=$merlinclash_dc_acl4ssrsel	
	emoji=$merlinclash_dc_subconverter_emoji
	udp=$merlinclash_dc_subconverter_udp
	appendtype=$merlinclash_dc_subconverter_append_type
	sort=$merlinclash_dc_subconverter_sort
	fnd=$merlinclash_dc_subconverter_fdn
	scv=$merlinclash_dc_subconverter_scv
	tfo=$merlinclash_dc_subconverter_tfo
	include=$merlinclash_dc_subconverter_include
	exclude=$merlinclash_dc_subconverter_exclude
	
	updateflag="start_online_update"
	if [ "$emoji" == "1" ]; then
		emoji="true"
	else
		emoji="false"
	fi
	if [ "$udp" == "1" ]; then
		udp="true"
	else
		udp="false"
	fi
	if [ "$appendtype" == "1" ]; then
		appendtype="true"
	else
		appendtype="false"
	fi
	if [ "$sort" == "1" ]; then
		sort="true"
	else
		sort="false"
	fi
	if [ "$fnd" == "1" ]; then
		fnd="true"
	else
		fnd="false"
	fi
	if [ "$scv" == "1" ]; then
		scv="true"
	else
		scv="false"
	fi
	if [ "$tfo" == "1" ]; then
		tfo="true"
	else
		tfo="false"
	fi
	#echo_date "$scv | $tfo " >> $LOG_FILE
	#merlinc_link=$merlinclash_links3
	#20200807处理%0A替换成%7C，换行替换成|
	merlinc_link=$(echo $merlinclash_dc_links3 | sed 's/%0A/%7C/g')
		upname_tmp="$merlinclash_dc_uploadrename4"
		#echo_date "订阅文件重命名为：$upname_tmp" >> $LOG_FILE
		time=$(date "+%Y%m%d-%H%M%S")
		newname=$(echo $time | awk -F'-' '{print $2}')
		echo_date "订阅规则类型是：$(get_acl4ssrsel_name $acl4ssrsel)"
		echo_date "subconverter进程：$(pidof subconverter)" >> $LOG_FILE
		echo_date "即将开始转换，需要一定时间，请等候处理" >> $LOG_FILE
		sleep 3s
		case $acl4ssrsel in
		MC_Common)
			_name="MCC_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		MC_Area_Fallback)
			_name="MAF_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		MC_Area_Urltest)
			_name="MAU_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Urltest.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;	
		MC_Area_NoAuto)
			_name="MAUN_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;	
		MC_Area_Media)
			_name="MAM_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Media.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		MC_Area_Media_NoAuto)
			_name="MAMN_"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Media_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		Online)
			_name="OL_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online.ini"			
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		AdblockPlus)
			_name="AP_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_AdblockPlus.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		NoAuto)
			_name="NA_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_NoAuto.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		NoReject)
			_name="NR_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_NoReject.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoReject.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Mini)
			_name="Mini_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Mini_AdblockPlus)
			_name="MAP_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_AdblockPlus.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Mini_NoAuto)
			_name="MNA_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_NoAuto.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Mini_Fallback)
			_name="MF_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_Fallback.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Mini_MultiMode)
			_name="MMM_"
			#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_MultiMode.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_MultiMode.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Full)
			_name="Full_"
			#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Full_NoAuto)
			_name="FNA_"
			#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full_NoAuto.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		Full_AdblockPlus)
			_name="FAP_"
			#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full_AdblockPlus.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Full_Netflix)
			_name="FNX_"
			#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full_Netflix.ini"
			links="http://localhost:25500/sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_Netflix.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		esac
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
						failed_warning_clash
					fi
				fi
			else
				failed_warning_clash
			fi
	#fi
}

start_regular_update_hnd(){
	#$name $type $link $clashtarget $acltype $emoji $udp $appendtype $sort $fnd $include $exclude $scv $tfo
	#$1    $2    $3    $4           $5       $6      $7    $8         $9   ${10} ${11}    ${12}   ${13} ${14}
	emoji=$6
	echo_date "emoji:$emoji" >> $LOG_FILE

	udp=$7
	echo_date "udp:$udp" >> $LOG_FILE

	appendtype=$8
	echo_date "append_type:$appendtype" >> $LOG_FILE

	sort=$9
	echo_date "sort:$sort" >> $LOG_FILE

	fnd=${10}
	echo_date "fnd:$fnd" >> $LOG_FILE
	
	scv=${13}
	echo_date "scv:$scv" >> $LOG_FILE

	tfo=${14}
	echo_date "tfo:$tfo" >> $LOG_FILE

	include=${11}
	echo_date "include:$include" >> $LOG_FILE

	exclude=${12}
	echo_date "exclude:$exclude" >> $LOG_FILE

	updateflag="start_regular_update"
	if [ "$emoji" == "1" ]; then
		emoji="true"
	else
		emoji="false"
	fi
	if [ "$udp" == "1" ]; then
		udp="true"
	else
		udp="false"
	fi
	if [ "$appendtype" == "1" ]; then
		appendtype="true"
	else
		appendtype="false"
	fi
	if [ "$sort" == "1" ]; then
		sort="true"
	else
		sort="false"
	fi
	if [ "$fnd" == "1" ]; then
		fnd="true"
	else
		fnd="false"
	fi
	if [ "$scv" == "1" ]; then
		scv="true"
	else
		scv="false"
	fi
	if [ "$tfo" == "1" ]; then
		tfo="true"
	else
		tfo="false"
	fi
	#merlinc_link=$3	
	merlinc_link=$(echo $3 | sed 's/%0A/%7C/g')
	upname_tmp=$1
	acltype_tmp=$5
	merlinclash_clashtarget=$4
	dbus set merlinclash_clashtarget=$merlinclash_clashtarget
	echo_date "clashtarget: $merlinclash_clashtarget"
	echo_date "订阅地址是：$merlinc_link"
	echo_date "配置名是：$upname_tmp" >> $LOG_FILE
	echo_date "订阅规则类型是：$(get_acl4ssrsel_name $acltype_tmp)" >> $LOG_FILE
	echo_date "subconverter进程：$(pidof subconverter)" >> $LOG_FILE
	echo_date "即将开始转换，需要一定时间，请等候处理" >> $LOG_FILE
	sleep 3s
	case $acltype_tmp in
	MC_Common)
		_name="MCC_"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	MC_Area_Fallback)
		_name="MAF_"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"			
		;;
	MC_Area_Urltest)
		_name="MAU_"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Urltest.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
		;;
	MC_Area_NoAuto)
		_name="MAUN_"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
		;;	
	MC_Area_Media)
		_name="MAM_"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Media.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
		;;
	MC_Area_Media_NoAuto)
		_name="MAMN_"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FZHANG_Area_Media_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
		;;
	Online)
		_name="OL_"
		#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online.ini"			
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	AdblockPlus)
		_name="AP_"
		#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_AdblockPlus.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	NoAuto)
		_name="NA_"
		#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_NoAuto.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	NoReject)
		_name="NR_"
		#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_NoReject.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoReject.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini)
		_name="Mini_"
		#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini_AdblockPlus)
		_name="MAP_"
		#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_AdblockPlus.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini_NoAuto)
		_name="MNA_"
		#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_NoAuto.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini_Fallback)
		_name="MF_"
		#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_Fallback.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini_MultiMode)
		_name="MMM_"
		#links="https://subcon.py6.pw/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Mini_MultiMode.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_MultiMode.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Full)
		_name="Full_"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Full_NoAuto)
		_name="FNA_"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full_NoAuto.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Full_AdblockPlus)
		_name="FAP_"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full_AdblockPlus.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Full_Netflix)
		_name="FNX_"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2FACL4SSR_Online_Full_Netflix.ini"
		links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_Netflix.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	esac
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
	clashtarget=$merlinclash_clashtarget
	acl4ssrsel=$merlinclash_acl4ssrsel
	emoji=$merlinclash_subconverter_emoji
	udp=$merlinclash_subconverter_udp
	appendtype=$merlinclash_subconverter_append_type
	sort=$merlinclash_subconverter_sort
	fnd=$merlinclash_subconverter_fdn
	scv=$merlinclash_subconverter_scv
	tfo=$merlinclash_subconverter_tfo
	include=$merlinclash_subconverter_include
	exclude=$merlinclash_subconverter_exclude
	addr=$merlinclash_subconverter_addr
	updateflag="start_online_update"
	if [ "$emoji" == "1" ]; then
		emoji="true"
	else
		emoji="false"
	fi
	if [ "$udp" == "1" ]; then
		udp="true"
	else
		udp="false"
	fi
	if [ "$appendtype" == "1" ]; then
		appendtype="true"
	else
		appendtype="false"
	fi
	if [ "$sort" == "1" ]; then
		sort="true"
	else
		sort="false"
	fi
	if [ "$fnd" == "1" ]; then
		fnd="true"
	else
		fnd="false"
	fi
	if [ "$scv" == "1" ]; then
		scv="true"
	else
		scv="false"
	fi
	if [ "$tfo" == "1" ]; then
		tfo="true"
	else
		tfo="false"
	fi
	#echo_date "$scv | $tfo " >> $LOG_FILE
	#merlinc_link=$merlinclash_links3
	#20200807处理%0A替换成%7C，换行替换成|
	merlinc_link=$(echo $merlinclash_links3 | sed 's/%0A/%7C/g')
	#LINK_FORMAT=$(echo "$merlinc_link" | grep -E "^http|^https")
	#echo_date "订阅地址是：$LINK_FORMAT"
	#if [ -z "$LINK_FORMAT" ]; then
	#	echo_date "订阅地址错误！检测到你输入的订阅地址并不是标准网址格式！"
	#	sleep 2
	#	echo_date "退出订阅程序,请手动刷新退出" >> $LOG_FILE
	#else
		upname_tmp="$merlinclash_uploadrename4"
		#echo_date "订阅文件重命名为：$upname_tmp" >> $LOG_FILE
		time=$(date "+%Y%m%d-%H%M%S")
		newname=$(echo $time | awk -F'-' '{print $2}')
		#echo_date "subconverter进程：$(pidof subconverter)" >> $LOG_FILE
		echo_date "配置名是：$upname_tmp" >> $LOG_FILE
		echo_date "订阅规则类型是：$(get_acl4ssrsel_name $acl4ssrsel)" >> $LOG_FILE
		echo_date "订阅后端地址是：$addr" >> $LOG_FILE
		echo_date "即将开始转换，需要一定时间，请等候处理" >> $LOG_FILE
		sleep 3s
		case $acl4ssrsel in
		MC_Common)
			_name="MCC_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			
			;;
		MC_Area_Fallback)
			_name="MAF_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		MC_Area_Urltest)
			_name="MAU_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_Urltest.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		MC_Area_NoAuto)
			_name="MAN_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		MC_Area_Media_NoAuto)
			_name="MAMN_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_Media_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		MC_Area_Media)
			_name="MAM_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_Media.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
			;;
		Online)
			_name="OL_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"			
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		AdblockPlus)
			_name="AP_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		NoAuto)
			_name="NA_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		NoReject)
			_name="NR_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_NoReject.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoReject.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Mini)
			_name="Mini_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Mini_AdblockPlus)
			_name="MAP_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Mini_NoAuto)
			_name="MNA_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Mini_Fallback)
			_name="MF_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Mini_MultiMode)
			_name="MMM_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini_MultiMode.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_MultiMode.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Full)
			_name="Full_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Full.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Full_NoAuto)
			_name="FNA_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Full_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Full_AdblockPlus)
			_name="FAP_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Full_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		Full_Netflix)
			_name="FNX_"
			links="${addr}sub?target=$clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Full_Netflix.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#links="http://localhost:25500/sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_Netflix.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			;;
		esac
		if [ -n "$upname_tmp" ]; then
			upname="$_name$upname_tmp.yaml"
		else
			upname="$_name$newname.yaml"
		fi
			#links="${addr}sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fACL4SSR_Online.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
			#echo_date merlinclash_link=$merlinc_link >> $LOG_FILE
			#wget下载文件
			#wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$links"
			echo_date "订阅地址是：$links" >> $LOG_FILE
			UA='Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36';
			curl --user-agent "$UA" --connect-timeout 30 -s "$links" > /tmp/upload/$upname
			
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
					local blank2=$(cat /tmp/upload/$upname | grep -E " |The following link doesn't contain any valid node info")				
					if [ -n "$blank" ]; then
						echo_date "订阅链接可能有跳转，尝试更换wget进行下载..." >> $LOG_FILE
						rm /tmp/upload/$upname
						if [ -n $(echo $links | grep -E "^https") ]; then
							wget --no-check-certificate --timeout=30 -qO /tmp/upload/$upname "$links"
							#curl --connect-timeout 10 -s $mclink > /tmp/clash_subscribe_file1.txt
							
						else
							wget --timeout=30 -qO /tmp/upload/$upname "$links"		
						fi
					fi
					if [ -n "$blank2" ]; then
						echo_date "订阅链接可能有跳转，尝试更换wget进行下载..." >> $LOG_FILE
						rm /tmp/upload/$upname
						if [ -n $(echo $links | grep -E "^https") ]; then
							wget --no-check-certificate --timeout=30 -qO /tmp/upload/$upname "$links"
							#curl --connect-timeout 10 -s $mclink > /tmp/clash_subscribe_file1.txt
							
						else
							wget --timeout=30 -qO /tmp/upload/$upname "$links"					
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
						failed_warning_clash
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
	emoji=$6
	echo_date "emoji:$emoji" >> $LOG_FILE

	udp=$7
	echo_date "udp:$udp" >> $LOG_FILE

	appendtype=$8
	echo_date "append_type:$appendtype" >> $LOG_FILE

	sort=$9
	echo_date "sort:$sort" >> $LOG_FILE

	fnd=${10}
	echo_date "fnd:$fnd" >> $LOG_FILE
	
	scv=${13}
	echo_date "scv:$scv" >> $LOG_FILE

	tfo=${14}
	echo_date "tfo:$tfo" >> $LOG_FILE

	include=${11}
	echo_date "include:$include" >> $LOG_FILE

	exclude=${12}
	echo_date "exclude:$exclude" >> $LOG_FILE

	addr=${15}
	echo_date "addr:$addr" >> $LOG_FILE

	updateflag="start_regular_update"
	if [ "$emoji" == "1" ]; then
		emoji="true"
	else
		emoji="false"
	fi
	if [ "$udp" == "1" ]; then
		udp="true"
	else
		udp="false"
	fi
	if [ "$appendtype" == "1" ]; then
		appendtype="true"
	else
		appendtype="false"
	fi
	if [ "$sort" == "1" ]; then
		sort="true"
	else
		sort="false"
	fi
	if [ "$fnd" == "1" ]; then
		fnd="true"
	else
		fnd="false"
	fi
	if [ "$scv" == "1" ]; then
		scv="true"
	else
		scv="false"
	fi
	if [ "$tfo" == "1" ]; then
		tfo="true"
	else
		tfo="false"
	fi
	#merlinc_link=$3	
	merlinc_link=$(echo $3 | sed 's/%0A/%7C/g')
	upname_tmp=$1
	acltype_tmp=$5
	merlinclash_clashtarget=$4
	dbus set merlinclash_clashtarget=$merlinclash_clashtarget
	echo_date "clashtarget: $merlinclash_clashtarget"
	echo_date "订阅地址是：$merlinc_link"
	echo_date "配置名是：$upname_tmp"
	echo_date "后端地址是：$addr"
	echo_date "订阅规则类型是：$(get_acl4ssrsel_name $acltype_tmp)"
	#echo_date "subconverter进程：$(pidof subconverter)" >> $LOG_FILE
	echo_date "即将开始转换，需要一定时间，请等候处理" >> $LOG_FILE
	sleep 3s
	case $acltype_tmp in
	MC_Common)
		_name="MCC_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		
		;;
	MC_Area_Fallback)
		_name="MAF_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
		;;
	MC_Area_Urltest)
		_name="MAU_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_Urltest.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
		;;
	MC_Area_NoAuto)
		_name="MAN_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
		;;
	MC_Area_Media_NoAuto)
		_name="MAMN_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_Media_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
		;;
	MC_Area_Media)
		_name="MAM_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2fflyhigherpi%2fmerlinclash_clash_related%2fmaster%2fRule_config%2fZHANG_Area_Media.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"		
		;;
	Online)
		_name="OL_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"			
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	AdblockPlus)
		_name="AP_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	NoAuto)
		_name="NA_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	NoReject)
		_name="NR_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_NoReject.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_NoReject.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini)
		_name="Mini_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini_AdblockPlus)
		_name="MAP_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini_NoAuto)
		_name="MNA_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini_Fallback)
		_name="MF_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_Fallback.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Mini_MultiMode)
		_name="MMM_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Mini_MultiMode.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Mini_MultiMode.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Full)
		_name="Full_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Full.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Full_NoAuto)
		_name="FNA_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Full_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_NoAuto.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Full_AdblockPlus)
		_name="FAP_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Full_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_AdblockPlus.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	Full_Netflix)
		_name="FNX_"
		links="${addr}sub?target=$merlinclash_clashtarget&new_name=true&url=$merlinc_link&insert=false&config=https%3a%2f%2fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fconfig%2fACL4SSR_Online_Full_Netflix.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		#links="http://localhost:25500/sub?target=clash&new_name=true&url=$merlinc_link&insert=false&config=config%2FACL4SSR_Online_Full_Netflix.ini&include=$include&exclude=$exclude&append_type=$appendtype&emoji=$emoji&udp=$udp&fdn=$fdn&sort=$sort&scv=$scv&tfo=$tfo"
		;;
	esac
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
			#虽然为0但是还是要检测下是否下载到正确的内容
			echo_date "检查下载是否正确" >> $LOG_FILE
			#订阅地址有跳转
			local blank=$(cat /tmp/upload/$upname | grep -E " |Redirecting|301")
			local blank2=$(cat /tmp/upload/$upname | grep -E " |The following link doesn't contain any valid node info")				
			if [ -n "$blank" ]; then
				echo_date "订阅链接可能有跳转，尝试更换wget进行下载..." >> $LOG_FILE
				rm /tmp/upload/$upname
				if [ -n $(echo $links | grep -E "^https") ]; then
					wget --no-check-certificate --timeout=30 -qO /tmp/upload/$upname $links
					#curl --connect-timeout 10 -s $mclink > /tmp/clash_subscribe_file1.txt
					
				else
					wget --timeout=30 -qO /tmp/upload/$upname $links					
				fi
			fi
			if [ -n "$blank2" ]; then
				echo_date "订阅链接可能有跳转，尝试更换wget进行下载..." >> $LOG_FILE
				rm /tmp/upload/$upname
				if [ -n $(echo $links | grep -E "^https") ]; then
					wget --no-check-certificate --timeout=30 -qO /tmp/upload/$upname "$links"
					#curl --connect-timeout 10 -s $mclink > /tmp/clash_subscribe_file1.txt
					
				else
					wget --timeout=30 -qO /tmp/upload/$upname "$links"					
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
				failed_warning_clash
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
				if [ "$mcflag" == "HND" ]; then
					echo_date "【SubConverter本地转换】配置名存在，覆写" >> $LOG_FILE
					sed -i "$name_tmp d" $dictionary
					echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"clashtarget\":\"$clashtarget\",\"acltype\":\"$acl4ssrsel\",\"emoji\":\"$emoji\",\"udp\":\"$udp\",\"appendtype\":\"$appendtype\",\"sort\":\"$sort\",\"fnd\":\"$fnd\",\"include\":\"$include\",\"exclude\":\"$exclude\",\"scv\":\"$scv\",\"tfo\":\"$tfo\" >> $dictionary
					#sed -i "s/^\"name\":\"$upname\",*$/^\"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"clashtarget\":\"$merlinclash_clashtarget\",\"acltype\":\"$merlinclash_acl4ssrsel\",\"emoji\":\"$merlinclash_subconverter_emoji\",\"udp\":\"$merlinclash_subconverter_udp\",\"appendtype\":\"$merlinclash_subconverter_append_type\",\"sort\":\"$merlinclash_subconverter_sort\",\"fnd\":\"$merlinclash_subconverter_fdn\",\"include\":\"$merlinclash_subconverter_include\",\"exclude\":\"$merlinclash_subconverter_exclude\",\"scv\":\"$merlinclash_subconverter_scv\",\"tfo\":\"$merlinclash_subconverter_tfo\"/g" $dictionary
				else
					echo_date "【ACL4SSR转换处理】配置名存在，覆写" >> $LOG_FILE
					sed -i "$name_tmp d" $dictionary
					echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"clashtarget\":\"$clashtarget\",\"acltype\":\"$acl4ssrsel\",\"emoji\":\"$emoji\",\"udp\":\"$udp\",\"appendtype\":\"$appendtype\",\"sort\":\"$sort\",\"fnd\":\"$fnd\",\"include\":\"$include\",\"exclude\":\"$exclude\",\"scv\":\"$scv\",\"tfo\":\"$tfo\",\"addr\":\"$addr\" >> $dictionary
					#sed -i "s/^\"name\":\"$upname\",*$/^\"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"clashtarget\":\"$merlinclash_clashtarget\",\"acltype\":\"$merlinclash_acl4ssrsel\",\"emoji\":\"$merlinclash_subconverter_emoji\",\"udp\":\"$merlinclash_subconverter_udp\",\"appendtype\":\"$merlinclash_subconverter_append_type\",\"sort\":\"$merlinclash_subconverter_sort\",\"fnd\":\"$merlinclash_subconverter_fdn\",\"include\":\"$merlinclash_subconverter_include\",\"exclude\":\"$merlinclash_subconverter_exclude\",\"scv\":\"$merlinclash_subconverter_scv\",\"tfo\":\"$merlinclash_subconverter_tfo\"/g" $dictionary
				fi
			fi
		else
			#新增
			echo_date "配置名不存在，新增" >> $LOG_FILE
			if [ "$mcflag" == "HND" ]; then
				echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"clashtarget\":\"$clashtarget\",\"acltype\":\"$acl4ssrsel\",\"emoji\":\"$emoji\",\"udp\":\"$udp\",\"appendtype\":\"$appendtype\",\"sort\":\"$sort\",\"fnd\":\"$fnd\",\"include\":\"$include\",\"exclude\":\"$exclude\",\"scv\":\"$scv\",\"tfo\":\"$tfo\" >> $dictionary
			else
				echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"clashtarget\":\"$clashtarget\",\"acltype\":\"$acl4ssrsel\",\"emoji\":\"$emoji\",\"udp\":\"$udp\",\"appendtype\":\"$appendtype\",\"sort\":\"$sort\",\"fnd\":\"$fnd\",\"include\":\"$include\",\"exclude\":\"$exclude\",\"scv\":\"$scv\",\"tfo\":\"$tfo\",\"addr\":\"$addr\" >> $dictionary
			fi
		fi
	else
		#为初次订阅，直接写入
		echo_date "初次订阅，直接写入" >> $LOG_FILE
		if [ "$mcflag" == "HND" ]; then
			echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"clashtarget\":\"$clashtarget\",\"acltype\":\"$acl4ssrsel\",\"emoji\":\"$emoji\",\"udp\":\"$udp\",\"appendtype\":\"$appendtype\",\"sort\":\"$sort\",\"fnd\":\"$fnd\",\"include\":\"$include\",\"exclude\":\"$exclude\",\"scv\":\"$scv\",\"tfo\":\"$tfo\" >> $dictionary
		else
			echo \"name\":\"$upname\",\"link\":\"$merlinc_link\",\"type\":\"$subscription_type\",\"use\":\"0\",\"clashtarget\":\"$clashtarget\",\"acltype\":\"$acl4ssrsel\",\"emoji\":\"$emoji\",\"udp\":\"$udp\",\"appendtype\":\"$appendtype\",\"sort\":\"$sort\",\"fnd\":\"$fnd\",\"include\":\"$include\",\"exclude\":\"$exclude\",\"scv\":\"$scv\",\"tfo\":\"$tfo\",\"addr\":\"$addr\" >> $dictionary
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

	proxies_line=$(cat /tmp/upload/$upname | grep -n "^proxies:" | awk -F ":" '{print $1}')
	#20200902+++++++++++++++
	#COMP 左>右，值-1；左等于右，值0；左<右，值1
	port_line=$(cat /tmp/upload/$upname | grep -n "^port:" | awk -F ":" '{print $1}')
	echo_date "port:行数为$port_line" >> $LOG_FILE
	echo_date "proxies:行数为$proxies_line" >> $LOG_FILE
	if [ -z "$port_line" ] ; then
		echo_date "配置文件缺少port:开头行，无法创建yaml文件" >> $LOG_FILE
		#rm -rf /tmp/upload/$upname
		failed_warning_clash

	fi
	if [ -z "$proxies_line" ]; then
		echo_date "配置文件缺少proxies:开头行，无法创建yaml文件" >> $LOG_FILE
		#rm -rf /tmp/upload/$upname
		failed_warning_clash

	fi
	if [ -z "$para1" ] && [ -z "$para1_1" ]; then
		echo_date "clash配置文件不是合法的yaml文件，请检查订阅连接是否有误" >> $LOG_FILE
		#rm -rf /tmp/upload/$upname
		failed_warning_clash
	else
		echo_date "clash配置文件检查通过" >> $LOG_FILE
		flag=1
	fi
}

failed_warning_clash(){
	#rm -rf /tmp/upload/$upname
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
16)
	#set_lock
	if [ "$mcflag" == "HND" ]; then
		echo "" > $LOG_FILE
		http_response "$1"
		echo_date "subconverter转换处理" >> $LOG_FILE
		#20200802启动subconverter进程
		/koolshare/bin/subconverter >/dev/null 2>&1 &
		start_online_update_hnd >> $LOG_FILE
		sc_process=$(pidof subconverter)
		if [ -n "$sc_process" ]; then
			echo_date 关闭subconverter进程... >> $LOG_FILE
			killall subconverter >/dev/null 2>&1
		fi
		echo BBABBBBC >> $LOG_FILE
	else
		#set_lock
		echo "" > $LOG_FILE
		http_response "$1"
		echo_date "ACL4SSR转换处理" >> $LOG_FILE
		start_online_update_384 >> $LOG_FILE
		echo BBABBBBC >> $LOG_FILE
		#unset_lock
	fi
	;;
21)
	echo "" > $LOG_FILE
	http_response "$1"
	echo_date "dler三合一转换" >> $LOG_FILE
	#20200802启动subconverter进程
	/koolshare/bin/subconverter >/dev/null 2>&1 &
	start_dc_online_update_hnd >> $LOG_FILE
	sc_process=$(pidof subconverter)
	if [ -n "$sc_process" ]; then
		echo_date 关闭subconverter进程... >> $LOG_FILE
		killall subconverter >/dev/null 2>&1
	fi
	echo BBABBBBC >> $LOG_FILE
	;;
4)
	if [ "$mcflag" == "HND" ]; then
		echo_date "定时转换处理HND" >> $LOG_FILE
		#20200802启动subconverter进程
		/koolshare/bin/subconverter >/dev/null 2>&1 &
		#$name $type $link $clashtarget $acltype $emoji $udp $appendtype $sort $fnd $include $exclude $scv $tfo
		#$1    $2    $3    $4           $5       $6      $7    $8         $9   ${10} ${11}    ${12}   ${13} ${14}
		start_regular_update_hnd "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}" "${13}" "${14}" >> $LOG_FILE
		sc_process=$(pidof subconverter)
		if [ -n "$sc_process" ]; then
			echo_date 关闭subconverter进程... >> $LOG_FILE
			killall subconverter >/dev/null 2>&1
		fi
		echo BBABBBBC >> $LOG_FILE
	else
		echo_date "定时转换处理384" >> $LOG_FILE
		#$name $type $link $clashtarget $acltype $emoji $udp $appendtype $sort $fnd $include $exclude $scv $tfo
		#$1    $2    $3    $4           $5       $6      $7    $8         $9   ${10} ${11}    ${12}   ${13} ${14}
		start_regular_update_384 "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}" "${13}" "${14}" "${15}" >> $LOG_FILE
		echo BBABBBBC >> $LOG_FILE
	fi
	;;
esac

