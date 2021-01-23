#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt

rm -rf $LOG_FILE
echo_date "清空yaml文件" >> $LOG_FILE
tmp_path=/tmp/upload

rm -rf $tmp_path/*.yaml

http_response "success"
