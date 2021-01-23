#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOCK_FILE=/var/lock/UnblockMusic_create_certs.lock
LOG_FILE=/tmp/upload/merlinclash_log.txt
flag=1

create_certs(){
    cd /koolshare/scripts
    if [ ! -f openssl.cnf ]; then
	    echo_date "找不到openssl.cnf" >> $LOG_FILE
	    exit 1
    fi
    if [ -f /koolshare/bin/Music/ca.crt ] && [ -f /koolshare/bin/Music/server.crt ] && [ -f /koolshare/bin/Music/server.key ]; then
	    echo_date "已经有证书了！再次生成"
    fi
        ubm=$(pidof UnblockNeteaseMusic);
        if [ -n "$ubm" ]; then
            echo_date 关闭UnblockNeteaseMusic进程... >> $LOG_FILE
            # 有时候killall杀不了UnblockNeteaseMusic进程，所以用不同方式杀两次
            killall UnblockNeteaseMusic >/dev/null 2>&1
            kill -9 "$ubm" >/dev/null 2>&1
            flag=0
	    fi	
        #basepath=/koolshare/merlinclash/
        basepath=/tmp/upload
        cd $basepath
        mkdir -p certs 
        chmod 700 certs
        rm -rf $basepath/certs/*
        #rm -rf /koolshare/bin/Music/*
        crtpath=$basepath/certs
        extFile="$crtpath/extFile.txt"
        serverCrt="$crtpath/server.crt"
        serverKey="$crtpath/server.key"
        serverCsr="$crtpath/server.csr"
        caCrt="$crtpath/ca.crt"
        caKey="$crtpath/ca.key"
        echo_date "开始生成证书" >> $LOG_FILE
        # 生成 CA 私钥
        openssl genrsa -out "${caKey}" 2048
        # 生成 CA 证书
        openssl req -x509 -new -nodes -key "${caKey}" -sha256 -days 825 -out "${caCrt}" -subj "/C=CN/CN=UnblockNeteaseMusic Root CA/O=UnblockNeteaseMusic"
        # 生成服务器私钥
        openssl genrsa -out "${serverKey}" 2048
        # 生成证书签发请求
        openssl req -new -sha256 -key "${serverKey}" -out "${serverCsr}" -subj "/C=CN/L=Hangzhou/O=NetEase (Hangzhou) Network Co., Ltd/OU=IT Dept./CN=*.music.163.com"
        # 使用 CA 签发服务器证书
        touch "${extFile}"
        echo "basicConstraints=CA:FALSE
        keyUsage=digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
        extendedKeyUsage=serverAuth
        subjectAltName=DNS:music.163.com,DNS:*.music.163.com" >"${extFile}"
        openssl x509 -req -extfile "${extFile}" -days 825 -in "${serverCsr}" -CA "${caCrt}" -CAkey "${caKey}" -CAcreateserial -out "${serverCrt}"
        echo_date "证书生成完毕" >> $LOG_FILE
        #复制证书到/koolshare/bin/Music
        if [ -f /tmp/upload/certs/ca.crt ] && [ -f /tmp/upload/certs/server.crt ] && [ -f /tmp/upload/certs/server.key ]; then
            echo_date "证书生成成功！" >> $LOG_FILE
            
            cp -rf /tmp/upload/certs/ca.crt /koolshare/bin/Music
            cp -rf /tmp/upload/certs/server.crt /koolshare/bin/Music
            cp -rf /tmp/upload/certs/server.key /koolshare/bin/Music
            if [ "$flag" == "0" ]; then
                echo_date "重启UnblockNeteaseMusic" >> $LOG_FILE
                serverCrt="/koolshare/bin/Music/server.crt"
                serverKey="/koolshare/bin/Music/server.key"
                endponintset="";
                if [ -n "$merlinclash_unblockmusic_endpoint" ]; then
                    endponintset="-e"
                fi
                if [ "$merlinclash_unblockmusic_musicapptype" == "default" ]; then
                    if [ "$merlinclash_unblockmusic_bestquality" == "1" ]; then
                        /koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -m 0 -c "${serverCrt}" -k "${serverKey}" "${endponintset}" -b >/dev/null 2>&1 &
                    else
                        /koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -m 0 -c "${serverCrt}" -k "${serverKey}" "${endponintset}" >/dev/null 2>&1 &
                    fi
                else
                    if [ "$merlinclash_unblockmusic_bestquality" == "1" ]; then
                        /koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -o "$merlinclash_unblockmusic_musicapptype" -m 0 -c "${serverCrt}" -k "${serverKey}" "${endponintset}" -b >/dev/null 2>&1 &
                    else
                        /koolshare/bin/UnblockNeteaseMusic -p 5200 -sp 5300 -o "$merlinclash_unblockmusic_musicapptype" -m 0 -c "${serverCrt}" -k "${serverKey}" "${endponintset}" >/dev/null 2>&1 &
                    fi
                fi
            fi
           
        else
            echo_date "证书生成失败！" >> $LOG_FILE           
        fi
    
}


case $2 in
9)
	set_lock
	echo "" > $LOG_FILE
	http_response "$1"
	echo_date "网易云音乐解锁证书生成" >> $LOG_FILE
	create_certs >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE
	unset_lock
	;;
esac