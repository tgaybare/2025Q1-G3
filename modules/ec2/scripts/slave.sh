#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade -y
apt install -y nginx

systemctl enable nginx
systemctl start nginx

# Replace default Nginx page
cat > /var/www/html/index.html <<'EOF'
${html_content}
EOF

rm -rf /var/www/html/index.nginx*

if command -v ufw >/dev/null 2>&1; then
    ufw allow 'Nginx HTTP'
    ufw reload
fi
