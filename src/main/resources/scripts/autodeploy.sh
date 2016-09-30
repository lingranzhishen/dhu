export JAVA_HOME=$2

function error_exit() {
  if [ "$?" -ne "0" ]; then
     echo "[ERROR]:脚本执行异常" 
     exit 1
  fi
}

if test -d "$1/warbackup"
then
  echo -e "\r\n[step04]备份war包位置:$1/warbackup\n"
  while [ $(ls $1/warbackup|wc -l) -ge 2 ]
  do
    bakarray=(`ls -rt $1/warbackup/`)
    rmbak="$1/warbackup/"${bakarray[0]}
    echo "删除过期备份:$rmbak"
    rm -rf $rmbak 
  done
else 
  echo -e "\r\n[step04]创建war包备份文件夹..位置:$1/warbackup\n"
  mkdir $1/warbackup;
  error_exit
fi

echo -e "[step05]运行shutdown.sh停止tomcat服务...\n"
nohup /bin/sh $1/bin/./shutdown.sh &
error_exit

sleep 10

echo -e "[step06]检查tomcat进程停止tomcat服务...进程ID:`pgrep -f $1/`\n"
ps -ef |grep "$1/" |grep -v grep |awk '{print $2}' | while read pid
do
  kill -9 $pid
  error_exit
done
error_exit

sleep 5

if test -e "$1/webapps/ROOT" 
then
  echo -e "[step07]备份ROOT至:$1/warbackup\n"
  cd $1/webapps/ROOT/ && zip -r $1/warbackup/backup`date -d today +"%Y-%m-%d-%H_%M_%S"`.war * > /dev/null
  error_exit
fi

############## 作为生产环境自动部署时，需去掉'$1/logs/*' ##############
echo -e "[step08]删除旧项目文件及work文件...\n"
rm -rf $1/webapps/ROOT* $1/work $1/logs/*
error_exit

echo -e "[step09]移动war包至webapps文件夹并解压缩...\n" 
mv $1/ROOT.war $1/webapps/ROOT.war
unzip $1/webapps/ROOT.war -d $1/webapps/ROOT > /dev/null
rm -rf $1/webapps/ROOT.war
error_exit

########### 增加培训的额外处理修改BIN目录权限#################
if test -d "$1/webapps/ROOT/bin"
then 
  echo "[培训额外步骤] 修改bin目录权限"
  chmod -R u+x "$1/webapps/ROOT/bin"
fi

echo -e "[step10]启动tomcat...\n"
cd $1/bin/ && nohup $1/bin/./startup.sh &
error_exit

sleep 2

if [ "`pgrep -f $1/ |grep -v grep | wc -L`" == "0" ]
then
  echo -e "\n[ERROR]:tomcat未启动\n"
  exit 1
else
  echo -e "\n当前tomcat进程ID:`pgrep -f $1/ | grep -v grep`\n"
  echo "部署成功！"
  echo -e "------------------------------------------------------------------------"
fi
