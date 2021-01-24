#!/bin/sh

source /koolshare/scripts/base.sh

eval $(dbus export merlinclash)

if [ "$merlinclash_enable" == "1" ]; then
	echo 关闭clash插件！
	sh /koolshare/merlinclash/clashconfig.sh stop
	sleep 1s
fi

find /koolshare/init.d/ -name "*clash*" | xargs rm -rf

rm -rf /koolshare/bin/clash
rm -rf /koolshare/bin/yq
rm -rf /koolshare/bin/jq_c
rm -rf /koolshare/bin/haveged_c

#------网易云内容-----------
rm -rf //koolshare/bin/UnblockNeteaseMusic
rm -rf //koolshare/bin/Music

ipset flush music
ipset destroy music
#------网易云内容-----------

rm -rf /tmp/upload/yamls.txt
rm -rf /tmp/upload/*_status.txt
rm -rf /tmp/upload/merlinclash*
rm -rf /tmp/upload/dlercloud.log
rm -rf /tmp/upload/host_yaml.txt
rm -rf /tmp/upload/dns_redirhost.txt
rm -rf /tmp/upload/dns_redirhostp.txt
rm -rf /tmp/upload/dns_fakeip.txt
rm -rf /tmp/upload/razord
rm -rf /tmp/upload/yacd
rm -rf /tmp/dc*

rm -rf /koolshare/bin/subconverter
rm -rf /koolshare/res/icon-merlinclash.png
rm -rf /koolshare/res/clash-dingyue.png
rm -rf /koolshare/res/clash-kcp.jpg
rm -rf /koolshare/res/merlinclash.css
rm -rf /koolshare/res/mc-tablednd.js
rm -rf /koolshare/res/mc-menu.js
rm -rf /koolshare/merlinclash/Country.mmdb
rm -rf /koolshare/merlinclash/clashconfig.sh
rm -rf /koolshare/merlinclash/yaml_bak/*
rm -rf /koolshare/merlinclash/yaml_use/*
rm -rf /koolshare/merlinclash/yaml_basic/*
rm -rf /koolshare/merlinclash/yaml_dns/*
rm -rf /koolshare/merlinclash/subconverter/*
rm -rf /koolshare/merlinclash/dashboard/*
rm -rf /koolshare/scripts/clash*.sh
rm -rf /koolshare/scripts/openssl.cnf
rm -rf /koolshare/webs/Module_merlinclash.asp
rm -rf /koolshare/merlinclash
rm -rf /koolshare/scripts/merlinclash_install.sh
rm -rf /koolshare/scripts/uninstall_merlinclash.sh

dbus remove merlinclash_proxygroup_version
dbus remove merlinclash_proxygame_version
dbus remove merlinclash_scrule_version
dbus remove merlinclash_version_local
dbus remove merlinclash_patch_version
dbus remove merlinclash_dashboard_secret
dbus remove merlinclash_dc_ss
dbus remove merlinclash_dc_v2
dbus remove merlinclash_dc_trojan
dbus remove merlinclash_links
dbus remove merlinclash_links2
dbus remove merlinclash_kcp_param_2
dbus remove merlinclash_dc_name
dbus remove merlinclash_dc_passwd
dbus remove merlinclash_dc_token
dbus remove merlinclash_dnsedit_tag
dbus remove merlinclash_dns_edit_content1
dbus remove merlinclash_host_content1
dbus remove merlinclash_host_content1_tmp
dbus remove merlincalsh_flag
i=99
while [ $i -ge 0 ]; do
	dbus remove merlinclash_acl_content_$i
	dbus remove merlinclash_acl_type_$i
	dbus remove merlinclash_acl_lianjie_$i
	dbus remove merlinclash_device_name_$i
	dbus remove merlinclash_device_mode_$i
	dbus remove merlinclash_device_ip_$i
	let i--
done
dbus remove softcenter_module_merlinclash_install
dbus remove softcenter_module_merlinclash_version
