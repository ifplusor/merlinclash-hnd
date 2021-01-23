#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

dnsfile_path=/koolshare/merlinclash/yaml_dns
rh=$dnsfile_path/redirhost.yaml
rhp=$dnsfile_path/rhplus.yaml
fi=$dnsfile_path/fakeip.yaml
rhname_txt_1=""
rhname_txt_2=""
rhname_txt_3=""
rhfallback_txt_1=""
rhfallback_txt_2=""
rhfallback_txt_3=""
rhpname_txt_1=""
rhpname_txt_2=""
rhpname_txt_3=""
rhpfallback_txt_1=""
rhpfallback_txt_2=""
rhpfallback_txt_3=""
finame_txt_1=""
finame_txt_2=""
finame_txt_3=""
fifallback_txt_1=""
fifallback_txt_2=""
fifallback_txt_3=""
rhnameservers=$(yq r $rh dns.nameserver |sed 's/- //g')
rhfallbacks=$(yq r $rh dns.fallback |sed 's/- //g')
rhpnameservers=$(yq r $rhp dns.nameserver |sed 's/- //g')
rhpfallbacks=$(yq r $rhp dns.fallback |sed 's/- //g')
finameservers=$(yq r $fi dns.nameserver |sed 's/- //g')
fifallbacks=$(yq r $fi dns.fallback |sed 's/- //g')
###################redir-host########################
if [ -n "$rhnameservers" ]; then
    i=1
    for rs in $rhnameservers; do
        if [ $i -eq "1" ];then
            eval 'rhname_txt_1'=$rs;
        
        elif [ $i -eq "2" ];then
            eval 'rhname_txt_2'=$rs;
        
        elif [ $i -eq "3" ];then
            eval 'rhname_txt_3'=$rs;
        fi
        let i=i+1     
    done
fi
###########################################
if [ -n "$rhfallbacks" ]; then
    i=1
    for rf in $rhfallbacks; do
        if [ $i -eq "1" ];then
            eval 'rhfallback_txt_1'=$rf;
        
        elif [ $i -eq "2" ];then
            eval 'rhfallback_txt_2'=$rf;
        
        elif [ $i -eq "3" ];then
            eval 'rhfallback_txt_3'=$rf;
        fi
        let i=i+1     
    done
fi
#####################redir-host+######################
if [ -n "$rhpnameservers" ]; then
    i=1
    for rps in $rhpnameservers; do
        if [ $i -eq "1" ];then
            eval 'rhpname_txt_1'=$rps;
        
        elif [ $i -eq "2" ];then
            eval 'rhpname_txt_2'=$rps;
        
        elif [ $i -eq "3" ];then
            eval 'rhpname_txt_3'=$rps;
        fi
        let i=i+1     
    done
fi
###########################################
if [ -n "$rhpfallbacks" ]; then
    i=1
    for rpf in $rhpfallbacks; do
        if [ $i -eq "1" ];then
            eval 'rhpfallback_txt_1'=$rpf;
        
        elif [ $i -eq "2" ];then
            eval 'rhpfallback_txt_2'=$rpf;
        
        elif [ $i -eq "3" ];then
            eval 'rhpfallback_txt_3'=$rpf;
        fi
        let i=i+1     
    done
fi
#####################fake-ip######################
if [ -n "$finameservers" ]; then
    i=1
    for fs in $finameservers; do
        if [ $i -eq "1" ];then
            eval 'finame_txt_1'=$fs;
        elif [ $i -eq "2" ];then
            eval 'finame_txt_2'=$fs;
        elif [ $i -eq "3" ];then
            eval 'finame_txt_3'=$fs;
        fi 
        let i=i+1    
    done
    
fi
###########################################
if [ -n "$fifallbacks" ]; then
    i=1
    for ff in $fifallbacks; do
        if [ $i -eq "1" ];then
            eval 'fifallback_txt_1'=$ff;
        
        elif [ $i -eq "2" ];then
            eval 'fifallback_txt_2'=$ff;
        
        elif [ $i -eq "3" ];then
            eval 'fifallback_txt_3'=$ff;
        fi
        let i=i+1     
    done
fi

http_response "$rhname_txt_1@$rhname_txt_2@$rhname_txt_3@$rhfallback_txt_1@$rhfallback_txt_2@$rhfallback_txt_3@$rhpname_txt_1@$rhpname_txt_2@$rhpname_txt_3@$rhpfallback_txt_1@$rhpfallback_txt_2@$rhpfallback_txt_3@$finame_txt_1@$finame_txt_2@$finame_txt_3@$fifallback_txt_1@$fifallback_txt_2@$fifallback_txt_3"
