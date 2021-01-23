#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
#


[ ! -L "/tmp/upload/proxies.txt" ] && ln -s /koolshare/merlinclash/proxies.txt /tmp/upload/proxies.txt

http_response $1
