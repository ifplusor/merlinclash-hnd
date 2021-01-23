#!/bin/sh
 
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
upload_path=/tmp/upload

move_host(){
	#查找upload文件夹是否有刚刚上传的yaml文件，正常只有一份
	#name=$(find $uploadpath  -name "$yamlname.yaml" |sed 's#.*/##')
	echo_date "上传的文件名是$merlinclash_uploadhost" >> $LOG_FILE
	if [ -f "/tmp/upload/$merlinclash_uploadhost" ]; then
		#后台执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/koolshare/merlinclash/并命名为上传文件名.yaml
		#echo_date "后台执行yaml文件处理工作"
		#sh /koolshare/scripts/clash_yaml_sub.sh >/dev/null 2>&1 &
		echo_date "检查上传的host是否合法" >> $LOG_FILE
		#当文件存在hosts:开头的行数，视为合法
		para1=$(sed -n '/^hosts:/p' /tmp/upload/$merlinclash_uploadhost)
		if [ -n "$para1" ] ; then
			echo_date "上传的host合法" >> $LOG_FILE
			echo_date "开始替换hosts.yaml" >> $LOG_FILE
		
			cp -rf /tmp/upload/$merlinclash_uploadhost /koolshare/merlinclash/yaml_basic/$merlinclash_uploadhost
			rm -rf /tmp/upload/host_yaml.txt
			ln -sf /koolshare/merlinclash/yaml_basic/$merlinclash_uploadhost /tmp/upload/host_yaml.txt
			echo_date "替换hosts.yaml完成。替换后要生效，请重新启动clash" >> $LOG_FILE
		else
			echo_date "上传的host不合法，请检查，即将退出" >> $LOG_FILE
			rm -rf /tmp/upload/$merlinclash_uploadhost
			echo BBABBBBC >> $LOG_FILE
			exit 1
		fi
		
	else
		echo_date "没找到上传的host文件" >> $LOG_FILE
		rm -rf /tmp/upload/$merlinclash_uploadhost
		echo BBABBBBC >> $LOG_FILE
		exit 1
	fi


}

case $2 in
22)
	echo "本地上传host文件" > $LOG_FILE
	http_response "$1"
	move_host >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE	
	;;
esac