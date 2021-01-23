#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt

echo_date "download" >> $LOG_FILE
echo_date "定位文件" >> $LOG_FILE
filepath=/koolshare/merlinclash/yaml_use
tmp_path=/tmp/upload

filename=$(echo $merlinclash_delyamlsel.yaml)
echo_date "$filename" >> $LOG_FILE

cp -rf $filepath/$filename $tmp_path/$filename
if [ -f $tmp_path/$filename ]; then
   echo_date "文件已复制" >> $LOG_FILE
   http_response "$filename"
else
    echo_date "文件复制失败" >> $LOG_FILE
fi

