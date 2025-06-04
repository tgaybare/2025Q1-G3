#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt update -y && apt upgrade -y
apt install -y wget
wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
apt update -y
apt install zabbix-agent -y
sed -i "s/^Server=.*/Server=${master_server_ip}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive=.*/ServerActive=${master_server_ip}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^Hostname=.*/Hostname=${hostname}/" /etc/zabbix/zabbix_agentd.conf

systemctl enable zabbix-agent
systemctl start zabbix-agent

apt install firewalld -y
systemctl enable firewalld
systemctl start firewalld

# Install Nginx

apt install -y nginx

systemctl enable nginx
systemctl start nginx

# Replace default Nginx page
cat > /var/www/html/index.html <<'EOF'
${html_content}
EOF

rm -rf /var/www/html/index.nginx*

firewall-cmd --permanent --add-port=10050/tcp
firewall-cmd --permanent --add-port=10051/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

systemctl restart zabbix-agent.service
