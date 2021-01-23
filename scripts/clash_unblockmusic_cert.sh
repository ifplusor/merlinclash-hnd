#!/bin/sh

source /koolshare/scripts/base.sh
eval `dbus export merlinclash_`

filepath=/koolshare/bin/Music
filename=ca.crt
tmp_path=/tmp/upload

cp -rf $filepath/$filename $tmp_path/$filename
if [ -f $tmp_path/$filename ]; then
	http_response "$filename"
else
	http_response "FAIL"
fi
