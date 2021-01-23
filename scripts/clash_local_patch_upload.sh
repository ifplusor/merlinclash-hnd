#!/bin/sh
 
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
upload_path=/tmp/upload
patchname=$merlinclash_uploadpatchname
name=$(echo "$patchname"|sed 's/.tar.gz//g')
upload_file=/tmp/upload/$patchname
MODEL=$(nvram get productid)

yamlname=$merlinclash_yamlsel
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml

ROG_86U=0
EXT_NU=$(nvram get extendno)
EXT_NU=${EXT_NU%_*}

if [ -n "$(nvram get extendno | grep koolshare)" -a "$(nvram get productid)" == "RT-AC86U" -a "${EXT_NU}" -lt "81918" ];then
	ROG_86U=1
fi
# 判断固件需要什么UI
if [ "$MODEL" == "GT-AC5300" -o "$MODEL" == "GT-AX11000" -o "$ROG_86U" == "1" ];then
	# 官改固件，骚红皮肤
	ROG=1
fi

clean(){
	[ -n "$name" ] && rm -rf /tmp/clashpatch >/dev/null 2>&1
	rm -rf /tmp/upload/*.tar.gz >/dev/null 2>&1
}

check_patchname(){
	if [ -z "$merlinclash_patch_version" ]; then
		echo_date "为补丁版本赋初始值000" >> $LOG_FILE		
		merlinclash_patch_version="000"
		dbus set merlinclash_patch_version=$merlinclash_patch_version		
	fi
	chmod +x $upload_file
	rm -rf /tmp/clashpatch
	mkdir -p /tmp/clashpatch
	mv $upload_file /tmp/clashpatch
	cd /tmp/clashpatch

	echo_date 尝试解压补丁包 >> $LOG_FILE
	tar -zxvf $patchname >/dev/null 2>&1
	if [ "$?" == "0" ];then
		echo_date 解压完成！ >> $LOG_FILE
	else
		echo_date 解压错误，错误代码："$?"！ >> $LOG_FILE
		echo_date 估计是错误或者不完整的的离线安装包！ >> $LOG_FILE
		echo_date 删除相关文件并退出... >> $LOG_FILE
		cd
		clean
		echo BBABBBBC >> $LOG_FILE
		exit
	fi
	#检查补丁包是否有版本号文件，否则为不合法补丁包
	#echo_date "name=$name"
	patch_version=$(cat /tmp/clashpatch/$name/patch_version)
	#echo_date $patch_version

	if [ -n "$patch_version" ]; then
		patchv1=$(echo $patch_version | awk -F"." '{print $1}' | awk -F"-" '{print $2}')
		#0724
		patchbag=$(echo $patch_version | awk -F"." '{print $1}' | awk -F"-" '{print $3}')
		#01
		#首先检查补丁包版本名跟插件版本名；只有相等才往下处理
		mcverson=$(echo $merlinclash_version_local | awk -F"." '{print $1}')
		#0724
		patchlocal=$merlinclash_patch_version
		#0

		COMP=$(versioncmp $patchlocal $patchbag)
		#COMP状态，1为左<右, 0为左=右, -1为左>右
		if [ "$patchv1"x = "$mcverson"x ] && [ "$COMP" == "1" ]; then
			echo_date "版本校验通过!" >> $LOG_FILE
			local_patch_replace
		else
			echo_date "版本校验未通过!请检查补丁包及版本号是否正确！" >> $LOG_FILE
			cd
			clean
			echo BBABBBBC
			exit 1
		fi
	else
		echo_date "获取不到补丁包版本！" >> $LOG_FILE
		echo_date "清除上传文件，退出。" >> $LOG_FILE
		cd
		clean
		echo BBABBBBC
		exit 1
	fi



	
}

local_patch_replace(){
	echo_date 检测jffs分区剩余空间...
	SPACE_AVAL=$(df|grep jffs | awk '{print $4}')
	SPACE_NEED=$(du -s /tmp/clashpatch/$name | awk '{print $1}')
	if [ "$SPACE_AVAL" -gt "$SPACE_NEED" ];then
		echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 补丁安装需要"$SPACE_NEED" KB，空间满足，继续安装！	
		patch_upload_ver=$patch_version
		if [ -n "$patch_upload_ver" ]; then
			echo_date "上传补丁版本为：$patch_upload_ver" >> $LOG_FILE
			echo_date "开始替换处理" >> $LOG_FILE
			replace_patch
		else
			echo_date "上传的补丁包异常！！！" >> $LOG_FILE
			echo_date "清除上传文件，退出。" >> $LOG_FILE
			cd
			clean
			echo BBABBBBC
			exit 1
		fi
	else
		echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 补丁安装需要"$SPACE_NEED" KB，空间不足！
		echo_date 退出安装！
		cd
		clean
		exit 1
	fi
	
}

replace_patch(){
	echo_date "开始更新补丁!" >> $LOG_FILE
	if [ "$(pidof clash)" ];then
		echo_date "为了保证更新正确，先关闭clash主进程... " >> $LOG_FILE
		killall clash >/dev/null 2>&1
		move_patch
		sleep 1
		start_clash
	else
		move_patch
	fi
}
#更新补丁，检查setup.sh文件，存在更新，否则退出，重启clash；
#更新完成，重新对version赋值
#	CUR_VERSION=$(cat /koolshare/merlinclash/version)
#	dbus set merlinclash_version_local="$CUR_VERSION"
#	dbus set softcenter_module_merlinclash_version="$CUR_VERSION"
#	dbus set merlinclash_patch_version="$patchlocal"
move_patch(){
	echo_date "检查clash进程完毕，继续更新补丁... " >> $LOG_FILE
	install_patch
	echo_date "补丁更新完成" >> $LOG_FILE
	#更新版本号
	CUR_VERSION=$(cat /koolshare/merlinclash/version)
	dbus set merlinclash_version_local="$CUR_VERSION"
	dbus set softcenter_module_merlinclash_version="$CUR_VERSION"
	#对比版本号日期，如merlinclash_version日期>PATCH日期，意味着是跨版本初始补丁，将patchbg置为空
	localversion_first=$(echo $CUR_VERSION | awk -F"." '{print $1}')
	patchversion_mid=$(echo $patch_version | awk -F"." '{print $1}' | awk -F"-" '{print $2}')
	COMP=$(versioncmp $localversion_first $patchversion_mid)
	#COMP状态，1为左<右, 0为左=右, -1为左>右
	if [ "$COMP" == "-1" ]; then
		dbus set merlinclash_patch_version=""
	fi
	if [ "$COMP" == "0" ]; then
		dbus set merlinclash_patch_version="$patchbag"
	fi
	
	
	echo_date "更新版本号" >> $LOG_FILE
}

install_patch(){
	if [ -f /tmp/clashpatch/$name/setup.sh ];then
		INSTALL_SCRIPT=/tmp/clashpatch/$name/setup.sh
		echo_date "找到补丁安装文件" >> $LOG_FILE
		echo_date 运行安装脚本...
		sleep 1
		start-stop-daemon -S -q -x $INSTALL_SCRIPT $name 2>&1
		if [ "$?" != "0" ];then
			echo_date 补丁安装失败！退出离线安装！
			clean
			if [ "$merlinclash_enable" == "1" ];then
				echo_date 重启clash插件！
				start_clash
			fi
			echo BBABBBBC
			exit 1
		fi

		install_pid=$(ps | grep -w setup.sh | grep -v grep | awk '{print $1}')
		i=120
		until [ -z "$install_pid" ]
		do
			install_pid=$(ps | grep -w setup.sh | grep -v grep | awk '{print $1}')
			i=$(($i-1))
			if [ "$i" -lt 1 ];then
				echo_date 安装似乎出了点问题，请手动重启路由器后重新尝试...
				echo_date 删除相关文件并退出...
				sleep 1
				clean
				dbus remove "merlinclash_patch_version"
				echo_date ======================== end ============================
				echo BBABBBBC
				exit
			fi
			sleep 1
		done
	fi

	#echo_date 开始复制文件！ >> $LOG_FILE
	#echo_date 复制补丁文件！此步时间可能较长！
	
	#dir=/tmp/clashpatch/$name/clash
	#a=$(ls $dir | wc -l)
	#if [ $a -gt 0 ]; then
	#	cp -rf /tmp/clashpatch/$name/clash/clash /koolshare/bin/
	#	cp -rf /tmp/clashpatch/$name/clash/yq /koolshare/bin/
	#	cp -rf /tmp/clashpatch/$name/clash/Country.mmdb /koolshare/merlinclash/
	#	cp -rf /tmp/clashpatch/$name/clash/clashconfig.sh /koolshare/merlinclash/
	#fi
	
	#------网易云内容-----------
	#dir=/tmp/clashpatch/$name/Music
	#a=$(ls $dir | wc -l)
	#if [ $a -gt 0 ]; then
	#	cp -rf /tmp/clashpatch/$name/Music/* /koolshare/bin/Music/
	#fi
	#------网易云内容-----------
	
	
	#cp -rf /tmp/clashpatch/$name/version /koolshare/merlinclash/

	#dir=/tmp/clashpatch/$name/yaml_basic
	#a=$(ls $dir | wc -l)
	#if [ $a -gt 0 ]; then
	#	cp -rf /tmp/clashpatch/$name/yaml_basic/* /koolshare/merlinclash/yaml_basic/
	#fi

	#dir=/tmp/clashpatch/$name/yaml_dns
	#a=$(ls $dir | wc -l)
	#if [ $a -gt 0 ]; then
	#	cp -rf /tmp/clashpatch/$name/yaml_dns/* /koolshare/merlinclash/yaml_dns/
	#fi

	#dir=/tmp/clashpatch/$name/dashboard
	#a=$(ls $dir | wc -l)
	#if [ $a -gt 0 ]; then
	#	cp -rf /tmp/clashpatch/$name/dashboard/* /koolshare/merlinclash/dashboard/
	#fi
	

	#dir=/tmp/clashpatch/$name/scripts
	#a=$(ls $dir | wc -l)
	#if [ $a -gt 0 ]; then
	#	cp -rf /tmp/clashpatch/$name/scripts/* /koolshare/scripts/
	#fi
	
	#dir=/tmp/clashpatch/$name/webs
	#a=$(ls $dir | wc -l)
	#if [ $a -gt 0 ]; then
	#	cp -rf /tmp/clashpatch/$name/webs/* /koolshare/webs/
	#fi
	
	#dir=/tmp/clashpatch/$name/res
	#a=$(ls $dir | wc -l)
	#if [ $a -gt 0 ]; then
#		cp -rf /tmp/clashpatch/$name/res/* /koolshare/res/
#	fi
	
	
#	if [ "$ROG" == "1" ];then
#		cp -rf /tmp/clashpatch//$name/rog/res/merlinclash.css /koolshare/res/
#    fi

}
start_clash(){
	echo_date "开启clash进程... " >> $LOG_FILE

	/bin/sh /koolshare/merlinclash/clashconfig.sh restart
	cd
	rm -rf /tmp/clashpatch
}

close_in_five() {
	echo_date "插件将在5秒后自动关闭！！"
	local i=5
	while [ $i -ge 0 ]; do
		sleep 1
		echo_date $i
		let i--
	done
	dbus set merlinclash_enable="0"
	if [ "$merlinclash_unblockmusic_enable" == "1" ]; then
		sh /koolshare/scripts/clash_unblockneteasemusic.sh stop
	fi
	sh /koolshare/merlinclash/clashconfig.sh stop
}

case $2 in
15)
	echo "本地上传安装补丁包" > $LOG_FILE
	http_response "$1"
	check_patchname >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE	
	;;
esac