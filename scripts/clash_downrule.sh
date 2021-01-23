#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt

#echo_date "download" >> $LOG_FILE
#echo_date "定位文件" >> $LOG_FILE


backup_conf(){
	dbus list merlinclash_acl_ |  sed 's/=/=\"/' | sed 's/$/\"/g'|sed 's/^/dbus set /' | sed '1 isource /koolshare/scripts/base.sh' |sed '1 i#!/bin/sh' > /tmp/upload/clash_rulebackup.sh
}

remove_silent(){
	echo_date 先清除已有的参数... >> $LOG_FILE
	acls=`dbus list merlinclash_acl_ | cut -d "=" -f 1`
	for acl in $acls
	do
		echo_date 移除$acl 
		dbus remove $acl
	done
	echo_date "--------------------"
}

restore_sh(){
	echo_date 检测到自定义规则备份文件... >> $LOG_FILE
	echo_date 开始恢复... >> $LOG_FILE
	chmod +x /tmp/upload/clash_rulebackup.sh
	sh /tmp/upload/clash_rulebackup.sh
	echo_date 配置恢复成功！>> $LOG_FILE
}
restore_now(){
	[ -f "/tmp/upload/clash_rulebackup.sh" ] && restore_sh
	echo_date 一点点清理工作... >> $LOG_FILE
	rm -rf /tmp/upload/clash_rulebackup.sh
	echo_date 完成！>> $LOG_FILE
}

case $2 in
1)
	backup_conf
	http_response "$1"
	;;
23)
	echo "还原自定义规则" > $LOG_FILE
	http_response "$1"
	remove_silent 
	restore_now 
	echo BBABBBBC >>  $LOG_FILE
	;;
esac