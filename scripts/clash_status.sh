#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

pid_clash=$(pidof clash)
#pid_watchdog=$(ps | grep clash_watchdog.sh | grep -v grep | awk '{print $1}')
pid_watchdog=$(cru l | grep "clash_watchdog")
date=$(echo_date)
yamlname=$merlinclash_yamlsel
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml
lan_ipaddr=$(nvram get lan_ipaddr)
board_port="9990"
if [ ! -f $yamlpath ]; then
    host=''
    port=''
    secret=''
else
    host=$(yq r $yamlpath external-controller | awk -F":" '{print $1}')
    host_port=$(cat $yamlpath | awk -F": " '/external-controller/{print $2}')
    port=$(cat $yamlpath | awk -F: '/external-controller/{print $3}')
    secret=$(cat $yamlpath | awk '/secret:/{print $2}' | sed 's/"//g')
fi


if [ -n "$pid_clash" ]; then
    text1="<span style='color: #6C0'>$date Clash 进程运行正常！(PID: $pid_clash)</span>"
    #text3="<span style='color: gold'>面板host：$host</span>"
    text4="<span style='color: gold'>面板端口：$port</span>"
    text3="<span style='color: gold'>管理面板：$host_port</span>"
    text15="<span style='color: gold'>面板密码：$secret</span>"
else
    text1="<span style='color: red'>$date Clash 进程未在运行！</span>"
fi

if [ -n "$pid_watchdog" ]; then
    text2="<span style='color: #6C0'>$date Clash 看门狗运行正常！</span>"
else
    text2="<span style='color: gold'>$date Clash 看门狗未在运行！</span>"
fi
yamlsel_tmp2=$yamlname

[ ! -L "/tmp/upload/yacd" ] && ln -sf /koolshare/merlinclash/dashboard/yacd /tmp/upload/
[ ! -L "/tmp/upload/razord" ] && ln -sf /koolshare/merlinclash/dashboard/razord /tmp/upload/

#网易云音乐解锁状态
unblockmusic_pid=`ps|grep -w UnblockNeteaseMusic | grep -cv grep`
#unblockmusic_LOCAL_VER=$(/koolshare/bin/UnblockNeteaseMusic -v 2>/dev/null |awk '/Version/{print $2}')
unblockmusic_LOCAL_VER=$merlinclash_UnblockNeteaseMusic_version
if [ -n "$unblockmusic_LOCAL_VER" ]; then
    text8="<span style='color: gold'>插件版本： $unblockmusic_LOCAL_VER</span>"
else
    text8="<span style='color: red'>获取插件版本失败，请重新上传二进制！</span>"
fi


if [ "$unblockmusic_pid" -gt 0 ];then
    if [ "$merlinclash_unblockmusic_bestquality" == "1" ]; then
	    text9="<span style='color: gold'>运行中 | 已开启高音质</span>"
    else
        text9="<span style='color: gold'>运行中 | 未开启高音质</span>"
    fi
else
	text9="<span style='color: gold'>未启动</span>"
fi

#内置规则文件版本
pgver=$merlinclash_proxygroup_version
if [ "$pgver" != "" ]; then
    text10="<span style='color: gold'>当前版本：v$merlinclash_proxygroup_version</span>"
else    
    text10="<span style='color: gold'>当前版本：v0</span>"
fi
#内置游戏规则文件版本
ggver=$merlinclash_proxygame_version
if [ "$ggver" != "" ]; then
    text11="<span style='color: gold'>当前版本：g$merlinclash_proxygame_version</span>"
else    
    text11="<span style='color: gold'>当前版本：g0</span>"
fi
#内置SC规则文件版本
scver=$merlinclash_scrule_version
if [ "$scver" != "" ]; then
    text13="<span style='color: gold'>当前版本：s$merlinclash_scrule_version</span>"
else    
    text13="<span style='color: gold'>当前版本：s0</span>"
fi
#补丁包版本
patchver=$merlinclash_patch_version
if [ "$patchver" != "" ] || [ "$patchver" != "0" ]; then
    text12="<span style='display:table-cell;float: middle; color: gold'>【已装补丁版本】：$merlinclash_patch_version</span>"
else    
    text12="<span style='display:none;'>【已装补丁版本】：</span>"
fi

if [ "$yamlname" != "" ]; then
    text14="<span style='display:table-cell;float: middle; color: gold'>当前配置为：$yamlname</span>"
fi

http_response "$text1@$text2@$host@$port@$secret@$text3@$text4@$yamlsel_tmp2@$text8@$text9@$text10@$text11@$text12@$text13@$text14@$text15@$secret"
