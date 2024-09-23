#!/bin/bash

mkdir /root/.cloudflared
wget -qO /root/.cloudflared/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /root/.cloudflared/cloudflared

echo root:"$PASSWORD" | chpasswd root
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g;s/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service ssh restart

ARGO_RUN="cloudflared tunnel --no-autoupdate --logfile /root/.cloudflared/log.log run --token ${ARGO_AUTH}"

cat > /etc/supervisor/conf.d/damon.conf << EOF
[supervisord]
nodaemon=true
logfile=/dev/null
pidfile=/run/supervisord.pid

[program:argo]
command=/root/.cloudflared/$ARGO_RUN
autostart=true
autorestart=true
stderr_logfile=/dev/null
stdout_logfile=/dev/null
EOF

nginx
supervisord -c /etc/supervisor/supervisord.conf
