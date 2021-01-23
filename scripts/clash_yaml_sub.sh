#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
lan_ip=$(nvram get lan_ipaddr)
uploadpath=/tmp/upload/
fp=/koolshare/merlinclash/yaml_bak
rm -rf /tmp/upload/clash_error.log
rm -rf /tmp/upload/dns_read_error.log
name=$(find $uploadpath  -name "*.yaml" |sed 's#.*/##')
#echo_date "yaml文件名是：$name" >> $LOG_FILE
yaml_tmp=/tmp/upload/$name
#echo_date "yaml_tmp路径是：$yaml_tmp" >> $LOG_FILE
head_tmp=/koolshare/merlinclash/yaml_basic/head.yaml
hosts_tmp=/koolshare/merlinclash/yaml_basic/hosts.yaml

echo_date "yaml文件【后台处理ing】，请在日志页面看到完成后，再启动Clash！！！" >> $LOG_FILE
#echo_date "将标准头部文件复制一份到/tmp/" >>"$LOG_FILE"
#cp -rf /koolshare/merlinclash/yaml/head.yaml /tmp/head.yaml >/dev/null 2>&1 &
sleep 2s
#去注释
echo_date "文件格式标准化" >> $LOG_FILE
#将所有DNS都转化成dns
sed -i 's/DNS/dns/g' $yaml_tmp
#老格式处理
#当文件存在Proxy:开头的行数，将Proxy: ~替换成空格
para0=$(sed -n '/^\.\.\./p' $yaml_tmp)
if [ -n "$para0" ] ; then
    sed -i 's/^\.\.\.//g' $yaml_tmp
fi

#当文件存在Proxy:开头的行数，将Proxy: ~替换成空格
para1=$(sed -n '/^Proxy: ~/p' $yaml_tmp)
if [ -n "$para1" ] ; then
    sed -i 's/Proxy: ~//g' $yaml_tmp
fi

para2=$(sed -n '/^Proxy Group: ~/p' $yaml_tmp)
#当文件存在Proxy Group:开头的行数，将Proxy Group: ~替换成空格
if [ -n "$para2" ] ; then
    sed -i 's/Proxy Group: ~//g' $yaml_tmp
fi
#当文件存在奇葩声明，删除，重写
pg_line=$(grep -n "Proxy Group" $yaml_tmp | awk -F ":" '{print $1}' )
if [ -n "$pg_line" ] ; then
    sed -i "$pg_line d" $yaml_tmp
    sed -i "$pg_line i proxy-groups:" $yaml_tmp
fi
para3=$(sed -n '/Rule: ~/p' $yaml_tmp)
#当文件存在Rule:开头的行数，将Rule: ~替换成空格
if [ -n "$para3" ] ; then
    echo_date "将Rule:替换成rules:" >> $LOG_FILE
    sed -i 's/Rule: ~//g' $yaml_tmp
fi
#当文件存在Proxy:开头的行数，将Proxy:替换成proxies:
para1=$(sed -n '/^Proxy:/p' $yaml_tmp)
if [ -n "$para1" ] ; then
    sed -i 's/Proxy:/proxies:/g' $yaml_tmp
fi

para2=$(sed -n '/^Proxy Group:/p' $yaml_tmp)
#当文件存在Proxy Group:开头的行数，将Proxy Group:替换成proxy-groups:
if [ -n "$para2" ] ; then
    sed -i 's/Proxy Group:/proxy-groups:/g' $yaml_tmp
fi

para3=$(sed -n '/Rule:/p' $yaml_tmp)
#当文件存在Rule:开头的行数，将Rule:替换成rules:
if [ -n "$para3" ] ; then
    sed -i 's/Rule:/rules:/g' $yaml_tmp
fi

proxies_line=$(cat $yaml_tmp | grep -n "^proxies:" | awk -F ":" '{print $1}')
#20200902+++++++++++++++
#COMP 左>右，值-1；左等于右，值0；左<右，值1
port_line=$(cat $yaml_tmp | grep -n "^port:" | awk -F ":" '{print $1}')
echo_date "port:行数为$port_line" >> $LOG_FILE
echo_date "proxies:行数为$proxies_line" >> $LOG_FILE

COMP=$(versioncmp $proxies_line $port_line)
if [ "$COMP" == "-1" ];then
    echo_date "proxies行数大于port行数，说明port在proxies之前，截取proxies到末尾内容" >> $LOG_FILE
    tail +$proxies_line $yaml_tmp > /tmp/a.yaml
elif [ "$COMP" == "1" ];then
    echo_date "proxies行数小于port行数，说明port在proxies之后，截取proxies到port行-1之间内容" >> $LOG_FILE
    b=$(($port_line-1))
    sed -n "$proxies_line,$b p" $yaml_tmp > /tmp/a.yaml
fi
#20200902---------------
#tail +$proxies_line $yaml_tmp > /tmp/a.yaml
cat /tmp/a.yaml > $yaml_tmp
echo_date "删除原文件头部内容" >> $LOG_FILE
#检查原文件是否存在头部参数,存在则删除，避免与后面处理重复
port=$(cat $yaml_tmp | grep -n "^port:" | awk -F ":" '{print $1}')
[ -n "$port" ] && sed -i "$port d" $yaml_tmp

sport=$(cat $yaml_tmp | grep -n "^socks-port:" | awk -F ":" '{print $1}')
[ -n "$sport" ] && sed -i "$sport d" $yaml_tmp

rport=$(cat $yaml_tmp | grep -n "^redir-port:" | awk -F ":" '{print $1}')
[ -n "$rport" ] && sed -i "$rport d" $yaml_tmp

allowlan=$(cat $yaml_tmp | grep -n "^allow-lan:" | awk -F ":" '{print $1}')
[ -n "$allowlan" ] && sed -i "$allowlan d" $yaml_tmp

mode=$(cat $yaml_tmp | grep -n "^mode:" | awk -F ":" '{print $1}')
[ -n "$mode" ] && sed -i "$mode d" $yaml_tmp

ll=$(cat $yaml_tmp | grep -n "^log-level:" | awk -F ":" '{print $1}')
[ -n "$ll" ] && sed -i "$ll d" $yaml_tmp

ec=$(cat $yaml_tmp | grep -n "^external-controller:" | awk -F ":" '{print $1}')
[ -n "$ec" ] && sed -i "$ec d" $yaml_tmp

ei=$(cat $yaml_tmp | grep -n "^experimental:" | awk -F ":" '{print $1}')
[ -n "$ei" ] && sed -i "$ei d" $yaml_tmp

irf=$(cat $yaml_tmp | grep -n "ignore-resolve-fail:" | awk -F ":" '{print $1}')
[ -n "$irf" ] && sed -i "$irf d" $yaml_tmp

eu=$(cat $yaml_tmp | grep -n "^external-ui:" | awk -F ":" '{print $1}')
[ -n "$eu" ] && sed -i "$eu d" $yaml_tmp

sec=$(cat $yaml_tmp | grep -n "^secret:" | awk -F ":" '{print $1}')
[ -n "$sec" ] && sed -i "$sec d" $yaml_tmp

hs=$(cat $yaml_tmp | grep -n "^hosts:" | awk -F ":" '{print $1}')
[ -n "$hs" ] && sed -i "$hs d" $yaml_tmp

rtr=$(cat $yaml_tmp | grep -n "router.asus.com:" | awk -F ":" '{print $1}')
[ -n "$rtr" ] && sed -i "$rtr d" $yaml_tmp
#插入一行免得出错
sed -i '$a' $yaml_tmp
cat $head_tmp >> $yaml_tmp
echo_date "标准头文件合并完毕" >> $LOG_FILE
#对external-controller赋值
#yq w -i $yaml_tmp external-controller $lan_ip:9990
sed -i "s/192.168.2.1:9990/$lan_ip:9990/g" $yaml_tmp

#写入hosts
#yq w -i $yaml_tmp 'hosts.[router.asus.com]' $lan_ip
#sed -i '$a hosts:' $yaml_tmp
#sed -i '$a \ \ router.asus.com: '"$lan_ip"'' $yaml_tmp
#20200904将host写入移到启动时候添加
#sed -i '$a' $yaml_tmp
#cat $hosts_tmp >> $yaml_tmp

#不再检查，直接用redir-host替换 20200721++++++++++++++++
#检查配置文件dns
#echo_date "检查配置文件dns" >> $LOG_FILE
#yq r $yaml_tmp dns.enable 1>/dev/null 2>/tmp/upload/dns_read_error.log
#dnserror=$(sed -n 1p /tmp/upload/dns_read_error.log | awk -F':' '{print $1}')
#if [ $dnserror == "Error" ]; then
#    echo_date "yq 读取异常，yaml文件可能存在格式问题，即将退出！" >> $LOG_FILE
#    echo_date "以下是错误原因：" >> $LOG_FILE
#    a=$(cat /tmp/upload/dns_read_error.log)
#    echo_date $a >> $LOG_FILE
#    rm -rf $yaml_tmp
#	echo_date "...MerlinClash！退出中..." >> $LOG_FILE
#	exit
#fi

#if [ $(yq r $yaml_tmp dns.enable) == 'true' ] && ([[ $(yq r $yaml_tmp dns.enhanced-mode) == 'fake-ip' || $(yq r $yaml_tmp dns.enhanced-mode) == 'redir-host' ]]); then
#    echo_date "上传Clash 配置文件DNS可用！" >> $LOG_FILE
#else
#    echo_date "在 Clash 配置文件中没有找到 DNS 配置！" >> $LOG_FILE
#echo_date "DNS默认采用redir-host模式" >> $LOG_FILE

#yq d -i $yaml_tmp dns
#yq m -x -i $yaml_tmp /koolshare/merlinclash/yaml/redirhost.yaml 1>/dev/null 2>/tmp/upload/clash_error.log
#cat /koolshare/merlinclash/yaml/redirhost.yaml >> $yaml_tmp
#fi

#不再检查，直接用redir-host替换 20200721---------------------


echo_date "移动yaml文件到/koolshare/merlinclash/yaml_bak/ 以" >> $LOG_FILE
echo_date "及/koolshare/merlinclash/yaml_use/目录下" >> $LOG_FILE
mv -f $yaml_tmp /koolshare/merlinclash/yaml_bak/$name
cp -rf /koolshare/merlinclash/yaml_bak/$name /koolshare/merlinclash/yaml_use/$name
#删除/upload可能残留的yaml格式文件
rm -rf /tmp/upload/*.yaml
rm -rf /tmp/a.yaml
#生成新的txt文件

rm -rf $fp/yamls.txt
echo_date "创建yaml文件列表" >> $LOG_FILE
#find $fp  -name "*.yaml" |sed 's#.*/##' >> $fp/yamls.txt
find $fp  -name "*.yaml" |sed 's#.*/##' |sed '/^$/d' | awk -F'.' '{print $1}' >> $fp/yamls.txt
#创建软链接
ln -s /koolshare/merlinclash/yaml_bak/yamls.txt /tmp/upload/yamls.txt
#
echo_date "配置文件【处理完成】，如下拉框没找到配置文件，请手动刷新" >>"$LOG_FILE"

#http_response "$text1@$text2@$host@$secret"
