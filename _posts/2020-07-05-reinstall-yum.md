---
layout: post
title: Centos7安装yum
tags: [centos, yum, linux]
description: "Centos7安装yum"
image: ''
---


### Centos7安装yum

##### 卸载yum（谨慎使用）
```bash
rpm -qa|grep yum|xargs rpm -ev --allmatches --nodeps
whereis yum |xargs rm -frv
whereis yum  # 验证是否删除
```

##### 安装yum
```bash
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/python-2.7.5-88.el7.x86_64.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/python-iniparse-0.4-9.el7.noarch.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/python-pycurl-7.19.0-19.el7.x86_64.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/python-chardet-2.2.1-3.el7.noarch.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/python-kitchen-1.1.1-5.el7.noarch.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/python-libs-2.7.5-88.el7.x86_64.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/python-urlgrabber-3.10-10.el7.noarch.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/python-devel-2.7.5-88.el7.x86_64.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/python-setuptools-0.9.8-7.el7.noarch.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/rpm-python-4.11.3-43.el7.x86_64.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/yum-3.4.3-167.el7.centos.noarch.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/yum-plugin-aliases-1.1.31-53.el7.noarch.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/yum-plugin-protectbase-1.1.31-53.el7.noarch.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/yum-metadata-parser-1.1.4-10.el7.x86_64.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/yum-plugin-fastestmirror-1.1.31-53.el7.noarch.rpm
wget http://mirrors.aliyun.com/centos/7/os/x86_64/Packages/yum-utils-1.1.31-53.el7.noarch.rpm

# 安装Python，如果出错，添加 --nodeps 选项
rpm -Uvh --replacepkgs python*.rpm

# 安装rpm-python
rpm -Uvh --replacepkgs rpm-python*.rpm

# 安装yum
rpm -Uvh --replacepkgs yum*.rpm

enjoy！
```
> 注意：`rpm -Uvh --replacepkgs python*.rpm`命令如果安装不成功需要添加：`--nodeps`选项即可！别说为什么，最后能用`yum`就行！

##### 替换源
```bash
# 替换源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

# 生成缓存
yum makecache
```

