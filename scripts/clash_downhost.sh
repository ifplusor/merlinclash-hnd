#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt

echo_date "download host文件" >> $LOG_FILE
echo_date "定位文件" >> $LOG_FILE
filepath=/koolshare/merlinclash/yaml_basic/hosts.yaml
tmp_path=/tmp/upload

rm -rf $tmp_path/hosts.yaml
cp -rf $filepath $tmp_path/hosts.yaml
if [ -f $tmp_path/hosts.yaml ]; then
   echo_date "文件已复制" >> $LOG_FILE
   http_response "hosts.yaml"
else
    echo_date "文件复制失败" >> $LOG_FILE
fi

