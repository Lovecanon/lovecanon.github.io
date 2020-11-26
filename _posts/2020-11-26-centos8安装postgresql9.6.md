### commands explaination
* `dnf module list`：列出所有可用的modules
* `dnf module list postgresql`：列出指定软件包的可用modules，Profiles列中的[i]表示已安装版本
* `dnf module install postgresql:9.6`：安装指定版本的postgresql
* `dnf module provides postgresql`
* `postgres -V`
* `dnf install postgresql-contrib`：该软件包为PostgreSQL数据库提供了一些附加功能

* `systemctl enable --now postgresql`：在系统启动时启动
* `postgresql-setup initdb`：初始化PostgreSQL数据库

##### 监听0.0.0.0和修改密码

```bash
# 监听0.0.0.0
[root@testdbR data]# vi /var/lib/pgsql/data/postgresql.conf
listen_addresses = '*'


# 修改密码
[root@testdbR data]# sudo -u postgres psql
psql (9.6.10)
输入 "help" 来获取帮助信息.

postgres=# 
postgres=# ALTER USER postgres WITH PASSWORD 'datatom.com';
ALTER ROLE
postgres=# 
postgres=# \q
[root@testdbR data]# systemctl restart postgresql
[root@testdbR data]# ss -nlt | grep 5432
LISTEN    0         128                0.0.0.0:5432             0.0.0.0:*       
LISTEN    0         128                   [::]:5432                [::]:*  

# 最后一步：编辑pg_hba.conf文件将服务器配置为接受远程连接
host    all             all             0.0.0.0/0                trust

# 附：打开防火墙5432端口
[root@testdbR data]# firewall-cmd --zone=public --add-port=5432/tcp --permanent
[root@testdbR data]# firewall-cmd --reload
```





