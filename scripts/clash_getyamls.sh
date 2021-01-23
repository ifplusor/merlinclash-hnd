#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
#
ln -s /koolshare/merlinclash/yaml_bak/yamls.txt /tmp/upload/yamls.txt

http_response $1

