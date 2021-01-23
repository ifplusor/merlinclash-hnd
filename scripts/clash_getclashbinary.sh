#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
#
if [ -f "/koolshare/merlinclash/clash_binary_history.txt" ];then 
    ln -s /koolshare/merlinclash/clash_binary_history.txt /tmp/upload/clash_binary_history.txt 
fi
http_response $1

