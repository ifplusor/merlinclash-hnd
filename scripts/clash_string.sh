#!/bin/sh

# 将 '\r' 转为 '\n'
sed -e 's//\n/g' -i "" "$1"
