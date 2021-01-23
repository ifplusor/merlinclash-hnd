#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
uploadpath=/tmp/upload


curl=$(which curl)
wget=$(which wget)

ipdb_url="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=oeEqpP5QI21N&suffix=tar.gz"

    if [ "x$wget" != "x" ] && [ -x $wget ]; then
           command="$wget --no-check-certificate $ipdb_url -O $uploadpath/ipdb.tar.gz"
    elif [ "x$curl" != "x" ] && [ test -x $curl ]; then
           command="$curl -k --compressed $ipdb_url -o $uploadpath/ipdb.tar.gz"
    else
           echo_date "没有找到 wget 或 curl，无法更新 IP 数据库！" >> $LOG_FILE
           http_response 'nodl'
           exit 1
    fi
    echo_date "开始下载最新 IP 数据库..." >> $LOG_FILE
    $command

    if [ ! -f "$uploadpath/ipdb.tar.gz" ]; then
        echo_date "下载 IP 数据库失败！退出更新" >> $LOG_FILE
        exit 1
    else
        echo_date "下载完成，开始解压" >> $LOG_FILE
        mkdir -p $uploadpath/ipdb
        tar zxvf $uploadpath/ipdb.tar.gz -C $uploadpath/ipdb

        chmod 644 $uploadpath/ipdb/GeoLite2-Country_*/*
        version=$(ls $uploadpath/ipdb | grep 'GeoLite2-Country' | sed "s|GeoLite2-Country_||g")
        echo_date "更新版本" >> $LOG_FILE
        cp -rf $uploadpath/ipdb/GeoLite2-Country_*/GeoLite2-Country.mmdb /koolshare/merlinclash/Country.mmdb

        echo_date "更新 IP 数据库至 $version 版本" >> $LOG_FILE
        dbus set merlinclash_ipdb_version=$version

        echo_date "清理临时文件..." >> $LOG_FILE
        rm -rf $uploadpath/ipdb.tar.gz
        rm -rf $uploadpath/ipdb

        echo_date "IP 数据库更新完成！" >> $LOG_FILE
        echo_date "注意！新版 IP 数据库将在下次启动 Clash 时生效！" >> $LOG_FILE
        sleep 1
    fi

