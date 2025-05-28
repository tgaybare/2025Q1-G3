#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export RDS_ENDPOINT="${rds_endpoint}"
export RDS_PORT="${rds_port}"

# Normaliza el endpoint para quitar el puerto si existe
RDS_ENDPOINT=$(echo "$RDS_ENDPOINT" | cut -d':' -f1)
export RDS_ENDPOINT

touch debugging.txt
echo "$RDS_ENDPOINT $RDS_PORT" > /debugging.txt

wget -q https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
apt-get update

apt-get install -y zabbix-server-mysql \
                   zabbix-frontend-php \
                   zabbix-apache-conf \
                   zabbix-sql-scripts \
                   zabbix-agent \
                   mysql-server

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

SQL_COMMANDS="\
CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin; \
CREATE USER IF NOT EXISTS 'zabbix'@'$PRIVATE_IP' IDENTIFIED BY 'password'; \
GRANT ALL ON zabbix.* TO 'zabbix'@'$PRIVATE_IP'; \
FLUSH PRIVILEGES;"

mysql -h "$RDS_ENDPOINT" --port "$RDS_PORT" -u admin -ppassword -e "$SQL_COMMANDS" >> /errors1.txt 2>&1

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -h "$RDS_ENDPOINT" --port "$RDS_PORT" --default-character-set=utf8mb4 -u zabbix -ppassword zabbix >> /errors2.txt 2>&1

# Configuración de Zabbix Server
# Configurar /etc/zabbix/zabbix_server.conf con los parámetros de la base de datos
sed -i "s/^#\? DBHost=.*/DBHost=$RDS_ENDPOINT/" /etc/zabbix/zabbix_server.conf
sed -i "s/^#\? DBPort=.*/DBPort=$RDS_PORT/" /etc/zabbix/zabbix_server.conf
sed -i "s/^#\? DBName=.*/DBName=zabbix/" /etc/zabbix/zabbix_server.conf
sed -i "s/^#\? DBUser=.*/DBUser=zabbix/" /etc/zabbix/zabbix_server.conf
sed -i "s/^#\? DBPassword=.*/DBPassword=password/" /etc/zabbix/zabbix_server.conf

### COMPLETAR CONFIGURACIÓN DE ZABBIX WEB SERVER AQUIÍ

# Una vez configurada la web, configurar /etc/zabbix/web/zabbix.conf.php con los parámetros de la base de datos
cat > /etc/zabbix/web/zabbix.conf.php << EOF
<?php
// Zabbix GUI configuration file.

\$DB['TYPE']			= 'MYSQL';
\$DB['SERVER']			= '$RDS_ENDPOINT';
\$DB['PORT']			= '$RDS_PORT';
\$DB['DATABASE']			= 'zabbix';
\$DB['USER']			= 'zabbix';
\$DB['PASSWORD']			= 'password';

// Schema name. Used for PostgreSQL.
\$DB['SCHEMA']			= '';

// Used for TLS connection.
\$DB['ENCRYPTION']		= true;
\$DB['KEY_FILE']			= '';
\$DB['CERT_FILE']		= '';
\$DB['CA_FILE']			= '';
\$DB['VERIFY_HOST']		= false;
\$DB['CIPHER_LIST']		= '';

// Vault configuration. Used if database credentials are stored in Vault secrets manager.
\$DB['VAULT']			= '';
\$DB['VAULT_URL']		= '';
\$DB['VAULT_PREFIX']		= '';
\$DB['VAULT_DB_PATH']		= '';
\$DB['VAULT_TOKEN']		= '';
\$DB['VAULT_CERT_FILE']		= '';
\$DB['VAULT_KEY_FILE']		= '';
// Uncomment to bypass local caching of credentials.
// \$DB['VAULT_CACHE']		= true;

// Uncomment and set to desired values to override Zabbix hostname/IP and port.
// \$ZBX_SERVER			= '';
// \$ZBX_SERVER_PORT		= '';

\$ZBX_SERVER_NAME		= 'zabbix';

\$IMAGE_FORMAT_DEFAULT	= IMAGE_FORMAT_PNG;

// Uncomment this block only if you are using Elasticsearch.
// Elasticsearch url (can be string if same url is used for all types).
//\$HISTORY['url'] = [
//	'uint' => 'http://localhost:9200',
//	'text' => 'http://localhost:9200'
//];
// Value types stored in Elasticsearch.
//\$HISTORY['types'] = ['uint', 'text'];

// Used for SAML authentication.
// Uncomment to override the default paths to SP private key, SP and IdP X.509 certificates, and to set extra settings.
//\$SSO['SP_KEY']			= 'conf/certs/sp.key';
//\$SSO['SP_CERT']			= 'conf/certs/sp.crt';
//\$SSO['IDP_CERT']		= 'conf/certs/idp.crt';
//\$SSO['SETTINGS']		= [];

// If set to false, support for HTTP authentication will be disabled.
// \$ALLOW_HTTP_AUTH = true;
?>
EOF

systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
