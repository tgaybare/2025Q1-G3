#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

wget -q https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
apt-get update

apt-get install -y zabbix-server-mysql \
                   zabbix-frontend-php \
                   zabbix-apache-conf \
                   zabbix-sql-scripts \
                   zabbix-agent \
                   mysql-server

mysql --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"
mysql -u root -ppassword <<SQL
CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
SQL

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -ppassword zabbix
sed -i "s/# DBPassword=.*/DBPassword=password/" /etc/zabbix/zabbix_server.conf
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
