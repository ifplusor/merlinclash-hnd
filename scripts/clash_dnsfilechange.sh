#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
dnsfile_path=/koolshare/merlinclash/yaml_dns
rh=$dnsfile_path/redirhost.yaml
rhp=$dnsfile_path/rhplus.yaml
fi=$dnsfile_path/fakeip.yaml
rm -rf /tmp/upload/dnsfile.log
nflag="0"
fflag="0"
#行数固定说明
#merlinclash_rh_nameserver1 第7行
#merlinclash_rh_nameserver2 第8行
#merlinclash_rh_nameserver3 第9行
#merlinclash_rh_fallback1   第11行
#merlinclash_rh_fallback2   第12行
#merlinclash_rh_fallback3   第13行
#cat $rh | grep -n $merlinclash_rh_nameserver1 | awk -F ":" '{print $1}' 获取指定字符串行数
decode_url_link(){
	local link=$1
	local len=$(echo $link | wc -L)
	local mod4=$(($len%4))
	if [ "$mod4" -gt "0" ]; then
		local var="===="
		local newlink=${link}${var:$mod4}
		echo -n "$newlink" | sed 's/-/+/g; s/_/\//g' | base64 -d 2>/dev/null
	else
		echo -n "$link" | sed 's/-/+/g; s/_/\//g' | base64 -d 2>/dev/null
	fi
}

echo_date "测试脚本是否调用" >> /tmp/upload/dnsfile.log
echo_date "$merlinclash_dnsedit_tag" >> /tmp/upload/dnsfile.log
#dns=$(dbus list merlinclash_dns_edit_content1 | grep -o "merlinclash_dns_edit_content1.*"|awk -F\= '{print $2}')
#dnstag=$(dbus list merlinclash_dnsedit_tag | grep -o "merlinclash_dnsedit_tag.*"|awk -F\= '{print $2}')
dns=$(decode_url_link $merlinclash_dns_edit_content1)
dnstag=$merlinclash_dnsedit_tag

if [ "$dnstag" == "redirhost" ]; then
	echo -e "$dns" > /koolshare/merlinclash/yaml_dns/redirhost.yaml
	echo_date "写入redirhost.yaml" >> /tmp/upload/dnsfile.log
	#删除空行
	sed -i '/^ *$/d' $rh
	rm -rf /tmp/upload/dns_redirhost.txt
	ln -sf $rh /tmp/upload/dns_redirhost.txt

fi
if [ "$dnstag" == "redirhostp" ]; then
	echo -e "$dns" > $rhp
	echo_date "rhplus.yaml" >> /tmp/upload/dnsfile.log
	#删除空行
	sed -i '/^ *$/d' $rhp
	
	rm -rf /tmp/upload/dns_redirhostp.txt
	ln -sf $rhp /tmp/upload/dns_redirhostp.txt
fi
if [ "$dnstag" == "fakeip" ]; then
	echo -e "$dns" > $fi
	echo_date "fakeip.yaml" >> /tmp/upload/dnsfile.log
	#删除空行
	sed -i '/^ *$/d' $fi
	rm -rf /tmp/upload/dns_fakeip.txt
	ln -sf $fi /tmp/upload/dns_fakeip.txt
fi

http_response "success"