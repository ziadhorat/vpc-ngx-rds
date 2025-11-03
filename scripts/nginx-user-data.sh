#!/bin/bash
set -x

PROJECT_NAME="${project_name}"
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

dnf update -y || true
dnf install -y nginx jq postgresql15 || exit 1

cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;
    location / { try_files $uri $uri/ =404; }
}
EOF

mkdir -p /usr/share/nginx/html
echo '<h1>Loading...</h1>' > /usr/share/nginx/html/index.html

cat > /usr/local/bin/health-check.sh <<'SCRIPT'
${health_check_script}
SCRIPT
chmod +x /usr/local/bin/health-check.sh

cat > /etc/systemd/system/health-check.service <<SERVICE_EOF
[Unit]
Description=Health Check
After=nginx.service

[Service]
Type=oneshot
Environment="PROJECT_NAME=$PROJECT_NAME"
ExecStart=/usr/local/bin/health-check.sh
SERVICE_EOF

cat > /etc/systemd/system/health-check.timer <<'EOF'
[Unit]
Description=Health Check Timer

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable nginx && systemctl start nginx
systemctl enable health-check.timer && systemctl start health-check.timer

echo "Done at $(date)" >> /var/log/user-data-complete.log
