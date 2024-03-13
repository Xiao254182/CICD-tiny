# CICD-tiny 一键部署精简版企业CICD流水线脚本

使用：将文件和所需的软件包全部放到部署节点的/root路径下，然后在/root路径下执行 `bash init.sh`

| **开发节点：** | **版本控制节点：** | **运维节点：** | **生产节点：** |
|---|---|---|---|
| Java | GitLab | Jenkins | Nginx (OpenResty) |
| Tomcat | Docker | Docker | |
| Node.js | Docker Compose | Docker Compose | |
| npm | Harbor | Ansible | |
| MySQL | httpd | Graylog | |

软件包下载地址，将所有软件包都放到控制节点的root目录下再执行init.sh脚本:
- GitLab: [https://packages.gitlab.com/gitlab/gitlab-ce/packages/el/7/gitlab-ce-16.9.2-ce.0.el7.x86_64.rpm/download.rpm](https://packages.gitlab.com/gitlab/gitlab-ce/packages/el/7/gitlab-ce-16.9.2-ce.0.el7.x86_64.rpm/download.rpm)
- Harbor: [https://github.com/goharbor/harbor/releases/download/v2.3.4/harbor-offline-installer-v2.5.3.tgz](https://github.com/goharbor/harbor/releases/download/v2.3.4/harbor-offline-installer-v2.5.3.tgz)
- Jenkins: [https://repo.huaweicloud.com/jenkins/redhat-stable/jenkins-2.346.3-1.1.noarch.rpm](https://repo.huaweicloud.com/jenkins/redhat-stable/jenkins-2.346.3-1.1.noarch.rpm)
- Graylog: [https://packages.graylog2.org/repo/el/stable/5.0/x86_64/graylog-server-5.0.13-1.x86_64.rpm](https://packages.graylog2.org/repo/el/stable/5.0/x86_64/graylog-server-5.0.13-1.x86_64.rpm)
