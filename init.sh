# bin/bash

#检查网络联通
ping -c1 baidu.com >> /dev/null
if [ $(echo $? -ne 0) ];then 
    echo "网络连接失败,请检查网络"
    exit 0
fi

#更换国内yum源
mkdir /etc/yum.repos.d/CentOS_bak || echo "ignore"
mv /etc/yum.repos.d/CentOS-* /etc/yum.repos.d/CentOS_bak || echo "ignore"
curl -O http://mirrors.aliyun.com/repo/Centos-7.repo && mv ./Centos-7.repo /etc/yum.repos.d/
yum clean all && yum makecache fast
echo "更新国内yum源成功"

#安装必要配置
echo "正在安装vim wget net-tools epel-* ansible"
yum install -y epel-* && yum install -y vim wget net-tools ansible
echo "安装完成"

echo "请选择您的集群节点ip地址"
#定义主机集群ip地址数组
ClusterIpName=("Develop" "Version" "Devops" "Produce")
#循环遍历输入节点ip
for i in ${ClusterIpName[@]}
do
    read -p "请输入${i}节点的ip地址: " ${i}_ip_addr
    # echo "${i}节点ip地址为: ${i}ip_addr"
done

#建立本地ssh密钥
ssh-keygen

#检测集群节点间网络是否通畅
for i in ${ClusterIpName[@]}
do
    ip_connect="${i}_ip_addr"
    ping -c1 "${!ip_connect}" >> /dev/null
    systemctl stop firewalld && systemctl disable firewalld && setenforce 0
    if [ $(echo $? -ne 0) ];then 
        echo "无法与${i}节点连接,请检查网络"
        exit 0
    else
        echo "连接${i}节点成功"
        #配置集群节点间信任
        ssh-copy-id ${!ip_connect}
        #配置ansible的hosts主机组
        echo "[${i}]" >> /etc/ansible/hosts
        echo "${!ip_connect}" >> /etc/ansible/hosts
    fi
done
ansible-playbook playbook.yml
echo "完成"
