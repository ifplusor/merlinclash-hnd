#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_node_mark.log

LOGFILE=/tmp/upload/merlinclash_log.txt

yamlname=$merlinclash_yamlsel
#配置文件路径
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml

filename=/koolshare/merlinclash/yaml_bak/subscription.txt
mcflag=$merlinclash_flag

a=$(ls $filename | wc -l)
if [ $a -gt 0 ]; then
	lines=$(cat $filename | wc -l)
	i=1
	while [ "$i" -le "$lines" ]
	do
		sleep 1s
		line=$(sed -n ''$i'p' "$filename")
		#echo $line
		#echo ""
		name=$(echo $line |grep -o "name.*"|awk -F\" '{print $3}')
		#名字去除.yaml后缀
		name=$(echo $name | awk -F"." '{print $1}')
		link=$(echo $line | grep -o "link.*"|awk -F\" '{print $3}')
		type=$(echo $line | grep -o "type.*"|awk -F\" '{print $3}')
		use=$(echo $line | grep -o "use.*"|awk -F\" '{print $3}')
		ruletype=$(echo $line | grep -o "ruletype.*"|awk -F\" '{print $3}')
		clashtarget=$(echo $line | grep -o "clashtarget.*"|awk -F\" '{print $3}')
		emoji=$(echo $line | grep -o "emoji.*"|awk -F\" '{print $3}')
		udp=$(echo $line | grep -o "udp.*"|awk -F\" '{print $3}')
		appendtype=$(echo $line | grep -o "appendtype.*"|awk -F\" '{print $3}')
		sort=$(echo $line | grep -o "sort.*"|awk -F\" '{print $3}')
		fnd=$(echo $line | grep -o "fnd.*"|awk -F\" '{print $3}')
		include=$(echo $line | grep -o "include.*"|awk -F\" '{print $3}')
		exclude=$(echo $line | grep -o "exclude.*"|awk -F\" '{print $3}')
		scv=$(echo $line | grep -o "scv.*"|awk -F\" '{print $3}')
		tfo=$(echo $line | grep -o "tfo.*"|awk -F\" '{print $3}')
		acltype=$(echo $line | grep -o "acltype.*"|awk -F\" '{print $3}')
		if [ "$mcflag" == "384" ]; then
			addr=$(echo $line | grep -o "addr.*"|awk -F\" '{print $3}')
		fi
		#echo "name=$name"
		#echo "link=$link"
		#echo "type=$type"
		#echo "use=$use"
		#echo "ruletype=$ruletype"
		#echo "acltype=$acltype"
		#echo "clashtarget=$clashtarget"
		#echo "emoji=$emoji"
		#echo "udp=$udp"
		#echo "appendtype=$appendtype"
		#echo "sort=$sort"
		#echo "fnd=$fnd"
		#echo "include=$include"
		#echo "exclude=$exclude"
		#echo "scv=$scv"
		#echo "tfo=$tfo"
		#echo "acltype=$acltype"
		#echo ""
		#根据type类型调用不同订阅方法
		case $type in
		1)
		#	echo "启动方案1"
			/bin/sh /koolshare/scripts/clash_online_yaml.sh "$name" "$type" "$link"
			sleep 3s
			;;
		2)
		#	echo "启动方案2"
			#名字带前缀，先去除前缀
			#name=$(echo $name | awk -F"_" '{print $2}')
			#从左向右截取第一个 _ 后的字符串
			name=$(echo ${name#*_}) 
			/bin/sh /koolshare/scripts/clash_online_yaml2.sh "$name" "$type" "$link" "$ruletype"
			sleep 3s
			;;
		3)
		#	echo "启动方案_2"
			#名字带前缀，先去除前缀
			#name=$(echo $name | awk -F"_" '{print $2}')
			#从左向右截取第一个 _ 后的字符串
			name=$(echo ${name#*_}) 
			if [ "$mcflag" == "HND" ]; then
				/bin/sh /koolshare/scripts/clash_online_yaml_2.sh "$name" "$type" "$link"
			else
				/bin/sh /koolshare/scripts/clash_online_yaml_2.sh "$name" "$type" "$link" "$addr"
			fi
			sleep 3s
			;;
		4)
			#名字带前缀，先去除前缀
		#	echo "启动方案4"
			#name=$(echo $name | awk -F"_" '{print $2}')
			#从左向右截取第一个 _ 后的字符串
			name=$(echo ${name#*_}) 
			if [ "$mcflag" == "HND" ]; then
				/bin/sh /koolshare/scripts/clash_online_yaml4.sh "$name" "$type" "$link" "$clashtarget" "$acltype" "$emoji" "$udp" "$appendtype" "$sort" "$fnd" "$include" "$exclude" "$scv" "$tfo"
			else
				/bin/sh /koolshare/scripts/clash_online_yaml4.sh "$name" "$type" "$link" "$clashtarget" "$acltype" "$emoji" "$udp" "$appendtype" "$sort" "$fnd" "$include" "$exclude" "$scv" "$tfo" "$addr"
			fi
			sleep 3s
			;;
		esac
		let i=i+1
	done
	#订阅后重启clash
	sleep 5s
	echo_date "订阅后重启clash" >> $LOG_FILE
	/bin/sh /koolshare/merlinclash/clashconfig.sh restart
fi


