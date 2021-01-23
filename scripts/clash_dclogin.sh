#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

name=$merlinclash_dc_name
passwd=$merlinclash_dc_passwd
echo_date "测试日志" > /tmp/upload/dlercloud.log
token_flag=0
#rm -rf /tmp/dc.txt
#rm -rf /tmp/dc_clash.txt
echo_date "1=$1" >> /tmp/upload/dlercloud.log
echo_date "2=$2" >> /tmp/upload/dlercloud.log

log_in () {
    #获取登陆文件
    #curl -s -d "email=$name&passwd=$passwd" https://dler.cloud/api/v1/login > /tmp/dc.txt
    curl -s -d "email=$name" --data-urlencode "passwd=$passwd" https://dler.cloud/api/v1/login > /tmp/dc.txt
    if [ -s /tmp/dc.txt ]; then
        echo_date "已获取文件，且文件不为空" >> /tmp/upload/dlercloud.log
        #line=$(sed -n ''$1'p' "/tmp/dc.txt")
        #ret=$(echo $line |grep -o "ret.*"|awk -F"[:,]" '{print $2}')
        ret=$(jq_c -r .ret /tmp/dc.txt)
        if [ "$ret" != "" ]; then
            echo_date "$ret" >> /tmp/upload/dlercloud.log
            if [ "$ret" == "200" ]; then
                #token=$(echo $line |grep -o "token.*"|awk -F"[:,]" '{print $2}'|awk -F\" '{print $2}')
                token=$(jq_c -r .data.token /tmp/dc.txt)
                plan=$(jq_c -r .data.plan /tmp/dc.txt)
                plan_time=$(jq_c -r .data.plan_time /tmp/dc.txt)
                money=$(jq_c -r .data.money /tmp/dc.txt)
                aff_money=$(jq_c -r .data.aff_money /tmp/dc.txt)
                usedTraffic=$(jq_c -r .data.usedTraffic /tmp/dc.txt)
                unusedTraffic=$(jq_c -r .data.unusedTraffic /tmp/dc.txt)
                integral=$(jq_c -r .data.Integral /tmp/dc.txt)

                #token_flag=1
                merlinclash_dc_token=$token
                merlinclash_dc_plan=$plan
                merlinclash_dc_plan_time=$plan_time
                merlinclash_dc_money=$money
                merlinclash_dc_aff_money=$aff_money
                merlinclash_dc_integral=$integral
                merlinclash_dc_usedTraffic=$usedTraffic
                merlinclash_dc_unusedTraffic=$unusedTraffic


                dbus set merlinclash_dc_token=$merlinclash_dc_token
                dbus set merlinclash_dc_plan=$merlinclash_dc_plan
                dbus set merlinclash_dc_plan_time=$merlinclash_dc_plan_time
                dbus set merlinclash_dc_money=$merlinclash_dc_money
                dbus set merlinclash_dc_aff_money=$merlinclash_dc_aff_money
                dbus set merlinclash_dc_integral=$merlinclash_dc_integral
                dbus set merlinclash_dc_usedTraffic=$merlinclash_dc_usedTraffic
                dbus set merlinclash_dc_unusedTraffic=$merlinclash_dc_unusedTraffic
                echo_date "登陆成功" >> /tmp/upload/dlercloud.log
                http_response "$ret"
            else
                echo_date "ret:$ret" >> /tmp/upload/dlercloud.log
                http_response "$ret"
            fi
        else
            http_response "获取返回值失败"
        fi
    else
        token=""
        merlinclash_dc_token=$token
        dbus set merlinclash_dc_token=$merlinclash_dc_token
        echo_date "文件为空，获取资料失败" >> /tmp/upload/dlercloud.log
        http_response "获取资料失败"
    fi
}
log_out () {
    token=""
    plan=""
    plan_time=""
    money=""
    usedTraffic=""
    unusedTraffic=""
    aff_money=""
    integral=""
    ss=""
    v2=""
    trojan=""

    merlinclash_dc_token=$token
    merlinclash_dc_plan=$plan
    merlinclash_dc_plan_time=$plan_time
    merlinclash_dc_money=$money
    merlinclash_dc_aff_money=$aff_money
    merlinclash_dc_integral=$integral
    merlinclash_dc_usedTraffic=$usedTraffic
    merlinclash_dc_unusedTraffic=$unusedTraffic
    merlinclash_dc_ss=$ss
    merlinclash_dc_v2=$v2
    merlinclash_dc_trojan=$trojan

    dbus set merlinclash_dc_token=$merlinclash_dc_token
    dbus set merlinclash_dc_plan=$merlinclash_dc_plan
    dbus set merlinclash_dc_plan_time=$merlinclash_dc_plan_time
    dbus set merlinclash_dc_money=$merlinclash_dc_money
    dbus set merlinclash_dc_aff_money=$merlinclash_dc_aff_money
    dbus set merlinclash_dc_integral=$merlinclash_dc_integral
    dbus set merlinclash_dc_usedTraffic=$merlinclash_dc_usedTraffic
    dbus set merlinclash_dc_unusedTraffic=$merlinclash_dc_unusedTraffic
    dbus set merlinclash_dc_ss=$merlinclash_dc_ss
    dbus set merlinclash_dc_v2=$merlinclash_dc_v2
    dbus set merlinclash_dc_trojan=$merlinclash_dc_trojan

    http_response "logout"
}

get_info () {
        name=$merlinclash_dc_name
        plan=$merlinclash_dc_plan
        plan_time=$merlinclash_dc_plan_time
        money=$merlinclash_dc_money
        aff_money=$merlinclash_dc_aff_money
        integral=$merlinclash_dc_integral
        usedTraffic=$merlinclash_dc_usedTraffic
        unusedTraffic=$merlinclash_dc_unusedTraffic
        echo_date "【2】token:$merlinclash_dc_token" >> /tmp/upload/dlercloud.log
        #获取订阅连接信息
        curl -s -d "access_token=$merlinclash_dc_token" https://dler.cloud/api/v1/managed/clash >/tmp/dc_clash.txt

        if [ -s /tmp/dc_clash.txt ]; then
            echo_date "已获取文件，且文件不为空" >> /tmp/upload/dlercloud.log
            #line=$(sed -n ''$1'p' "/tmp/dc_clash.txt")
            ret=$(jq_c -r .ret /tmp/dc_clash.txt)
                if [ "$ret" == "200" ]; then
                    echo_date "200:取得信息" >> /tmp/upload/dlercloud.log
                    ss=$(jq_c -r .ss /tmp/dc_clash.txt)
                    v2=$(jq_c -r .vmess /tmp/dc_clash.txt)
                    trojan=$(jq_c -r .trojan /tmp/dc_clash.txt)
                    merlinclash_dc_ss=$ss
                    merlinclash_dc_v2=$v2
                    merlinclash_dc_trojan=$trojan
                    dbus set merlinclash_dc_ss=$merlinclash_dc_ss
                    dbus set merlinclash_dc_v2=$merlinclash_dc_v2
                    dbus set merlinclash_dc_trojan=$merlinclash_dc_trojan
                    #echo $ss
                    #echo $v2
                    #echo $trojan
                    text1="<span style='color: gold'>$name</span>"
                    text2="<span style='color: gold'>$plan</span>"
                    text3="<span style='color: gold'>$plan_time</span>"
                    text4="<span style='color: gold'>$money</span>"
                    text5="<span style='color: gold'>$usedTraffic</span>"
                    text6="<span style='color: gold'>$unusedTraffic</span>"
                    text7="<span id='dc_ss_1' style='color: gold'>$ss</span>"
                    text8="<span id='dc_v2_1'style='color: gold'>$v2</span>"
                    text9="<span id='dc_trojan_1'style='color: gold'>$trojan</span>"
                    text10="<span style='color: gold'>$merlinclash_dc_token</span>"
                    text11="<span style='color: gold'>$aff_money</span>"
                    text12="<span style='color: gold'>$integral</span>"
                    echo_date "回传信息:$ret@@$text1@@$text2@@$text3@@$text4@@$text5@@$text6@@$text7@@$text8@@$text9@@$text10@@$text11@@$text12" >> /tmp/upload/dlercloud.log
                    http_response "$ret@@$text1@@$text2@@$text3@@$text4@@$text5@@$text6@@$text7@@$text8@@$text9@@$text10@@$text11@@$text12"
                else
                    http_response "$ret"
                    echo_date "403:获取资料失败" >> /tmp/upload/dlercloud.log

                fi
        else
            echo_date "文件为空，获取资料失败" >> /tmp/upload/dlercloud.log
            http_response "获取资料失败"
        fi
}
check_login(){
    #token=$merlinclash_dc_token
    #echo_date "【1】token:$token" >> /tmp/upload/dlercloud.log
    
    #curl -s -d "access_token=$token" https://dler.cloud/api/v1/information > /tmp/dc_token.txt

    #curl -s -d "email=$name&passwd=$passwd" https://dler.cloud/api/v1/information > /tmp/dc.txt
    curl -s -d "email=$name" --data-urlencode "passwd=$passwd" https://dler.cloud/api/v1/information > /tmp/dc.txt
    if [ -s /tmp/dc.txt ]; then
        echo_date "已获取文件，且文件不为空" >> /tmp/upload/dlercloud.log
        #line=$(sed -n ''$1'p' "/tmp/dc.txt")
        ret=$(jq_c -r .ret /tmp/dc.txt)
        if [ "$ret" == "200" ]; then
            #token仍然有效
            echo_date "获取info成功" >> /tmp/upload/dlercloud.log
            #token=$(jq_c -r .data.token /tmp/dc.txt)
            plan=$(jq_c -r .data.plan /tmp/dc.txt)
            plan_time=$(jq_c -r .data.plan_time /tmp/dc.txt)
            money=$(jq_c -r .data.money /tmp/dc.txt)
            aff_money=$(jq_c -r .data.aff_money /tmp/dc.txt)
            integral=$(jq_c -r .data.integral /tmp/dc.txt)
            usedTraffic=$(jq_c -r .data.usedTraffic /tmp/dc.txt)
            unusedTraffic=$(jq_c -r .data.unusedTraffic /tmp/dc.txt)
            
            #merlinclash_dc_token=$token
            merlinclash_dc_plan=$plan
            merlinclash_dc_plan_time=$plan_time
            merlinclash_dc_money=$money
            merlinclash_dc_aff_money=$aff_money
            merlinclash_dc_integral=$integral
            merlinclash_dc_usedTraffic=$usedTraffic
            merlinclash_dc_unusedTraffic=$unusedTraffic

            #dbus set merlinclash_dc_token=$merlinclash_dc_token
            dbus set merlinclash_dc_plan=$merlinclash_dc_plan
            dbus set merlinclash_dc_plan_time=$merlinclash_dc_plan_time
            dbus set merlinclash_dc_money=$merlinclash_dc_money
            dbus set merlinclash_dc_aff_money=$merlinclash_dc_aff_money
            dbus set merlinclash_dc_integral=$merlinclash_dc_integral
            dbus set merlinclash_dc_usedTraffic=$merlinclash_dc_usedTraffic
            dbus set merlinclash_dc_unusedTraffic=$merlinclash_dc_unusedTraffic

            text1="<span style='color: gold'>$name</span>"
            text2="<span style='color: gold'>$plan</span>"
            text3="<span style='color: gold'>$plan_time</span>"
            text4="<span style='color: gold'>$money</span>"
            text5="<span style='color: gold'>$usedTraffic</span>"
            text6="<span style='color: gold'>$unusedTraffic</span>"
            text7="<span id='dc_ss_1' style='color: gold'>$merlinclash_dc_ss</span>"
            text8="<span id='dc_v2_1' style='color: gold'>$merlinclash_dc_v2</span>"
            text9="<span id='dc_trojan_1' style='color: gold'>$merlinclash_dc_trojan</span>"
            text10="<span id='dc_token_1' style='color: gold'>$merlinclash_dc_token</span>"
            text11="<span style='color: gold'>$aff_money</span>"
            text12="<span style='color: gold'>$integral</span>"
            echo_date "回传信息:$ret@@$text1@@$text2@@$text3@@$text4@@$text5@@$text6@@$text7@@$text8@@$text9@@$text10@@$text11@@$text12" >> /tmp/upload/dlercloud.log
            http_response "$ret@@$text1@@$text2@@$text3@@$text4@@$text5@@$text6@@$text7@@$text8@@$text9@@$text10@@$text11@@$text12"
                
        else
            #登陆失效 
            echo_date "登陆失效" >> /tmp/upload/dlercloud.log
            log_out
        fi
    fi
}

case $2 in
login)
    echo_date "登陆校验" >> /tmp/upload/dlercloud.log
	log_in
	;;
token)
    echo_date "检测登陆有效性" >> /tmp/upload/dlercloud.log
	check_login
	;;
info)
    echo_date "读取信息" >> /tmp/upload/dlercloud.log
    get_info
    ;;
logout)
    echo_date "退出登录" >> /tmp/upload/dlercloud.log
    log_out
    ;;
esac


