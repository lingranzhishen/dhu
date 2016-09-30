#!/bin/sh
echo -e "\r\n[step01]构建包名为:ROOT.war\n"
src_host=$1
src_user=$2
src_pwd=$3
src_path=$4
src_war_path=$5
src_java_home=$6
deploy_path="/root/jenkins/scripts/autodeploy.sh"

echo -e "\r\n[step02]下载自动部署脚本..存放位置:$4\n"
/usr/bin/expect << EOF
spawn scp $deploy_path root@10.211.55.11:/root/tomcat-template/
set timeout 300
expect "root@10.211.55.11's password:"
set timeout 300
send "523588\r"
set timeout 300
send "exit\r"

EOF
