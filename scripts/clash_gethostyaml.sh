#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
#
[ ! -L "/tmp/upload/host_yaml.txt" ] && ln -s /koolshare/merlinclash/yaml_basic/hosts.yaml /tmp/upload/host_yaml.txt

http_response $1

