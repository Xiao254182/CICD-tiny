# bin/bash

#检查网络联通
ping -c1 baidu.com >> /dev/null
if [ $(echo $? -ne 0) ];then 
    echo "网络连接失败,请检查网络"
    exit 0
fi


Package=("gitlab-ce-16.9.2-ce.0.el7.x86_64.rpm" "graylog-server-5.0.13-1.x86_64.rpm" "harbor-offline-installer-v2.5.3.tgz" "jenkins-2.346.3-1.1.noarch.rpm")
for i in ${Package[@]} 
do 
    ls ${i}
    if [ $(echo $? -ne 0) ];then 
        echo "未找到${i}软件包，请先下载该软件包到本机/root/目录下"
        exit 0
    fi
done

#更换国内yum源
mkdir /etc/yum.repos.d/CentOS_bak || echo "ignore"
mv /etc/yum.repos.d/CentOS-* /etc/yum.repos.d/CentOS_bak || echo "ignore"
curl -O http://mirrors.aliyun.com/repo/Centos-7.repo && mv ./Centos-7.repo /etc/yum.repos.d/
yum clean all && yum makecache fast
echo "更新国内yum源成功"

#安装必要配置
echo "正在安装vim wget net-tools epel-* ansible"
yum install -y epel-* && yum install -y vim wget net-tools ansible sshpass
echo "安装完成"

#建立本地ssh密钥
ssh-keygen

echo "请选择您的集群节点ip地址"
#定义主机集群ip地址数组
ClusterIpName=("Develop" "Version" "Devops" "Produce")

#获取控制节点主机ip地址
ansible_ipaddr=$(ip a | grep -w inet | grep -w brd | awk '{print $2}' | sed "s/\/..*//g")

#检测集群节点间网络是否通畅
for i in ${ClusterIpName[@]}
do
#循环遍历输入节点ip
    read -p "请输入${i}节点的ip地址: " ${i}_ip_addr
    read -p "请输入${i}节点的密码: " ${i}_password
    ip_connect="${i}_ip_addr"
    ip_passwd="${i}_password"
    ping -c1 "${!ip_connect}" >> /dev/null
    systemctl stop firewalld && systemctl disable firewalld && setenforce 0
    if [ $(echo $? -ne 0) ];then 
        echo "无法与${i}节点连接,请检查网络"
        exit 0
    else
        echo "连接${i}节点成功"
		sed -i "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config
	    sshpass -p ${!ip_passwd} ssh-copy-id ${!ip_connect}
        cp /root/scp.exp.tmpl /root/${i}_scp.exp
        sed -e "s/passwd/${!ip_passwd}/g" -e "s/ansible_ipaddr/$ansible_ipaddr/g" /root/scp.exp.tmpl > /root/${i}_scp.exp
        #配置ansible的hosts主机组
        echo "[${i}]" >> /etc/ansible/hosts
        echo "${!ip_connect}" >> /etc/ansible/hosts
    fi
done

#配置Graylog目标节点
sed -i "s/ipaddr/${Produce_ip_addr}/g" /root/monitor.sh
#替换playbook剧本中的harbor仓库地址
sed -i "s/Version_ip/${Version_ip_addr}/g" /root/playbook.yml

#执行ansible剧本
ansible-playbook playbook.yml

#输出信息
printf "        GitLab:${Version_ip_addr}:80
        Harbor:${Version_ip_addr}:81
            username:admin
            password:Harbor12345
        httpd:${Version_ip_addr}:8000
        Jenkins:${Devops_ip_addr}:8080
            Temporary Password:
        Graylog:${Devops_ip_addr}:9000
            username:admin
            password:admin\n"
echo "完成"