#!/bin/bash

mkdir /root/.cloudflared
wget -qO /root/.cloudflared/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /root/.cloudflared/cloudflared

echo root:"$PASSWORD" | chpasswd root
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g;s/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service ssh restart

ARGO_RUN="cloudflared tunnel --no-autoupdate --logfile /root/.cloudflared/log.log run --token ${ARGO_AUTH}"

cat > /etc/supervisor/supervisord.conf << EOF
[unix_http_server]
file=/var/run/supervisor.sock   ; (the path to the socket file)
chmod=0700                       ; sockef file mode (default 0700)

[supervisord]
nodaemon=true
logfile=/dev/null
pidfile=/run/supervisord.pid
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
childlogdir=/var/log/supervisor            ; ('AUTO' child log dir, default $TEMP)


[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock 

[include]
files = /etc/supervisor/conf.d/*.conf

[program:argo]
command=/root/.cloudflared/$ARGO_RUN
autostart=true
autorestart=true
stderr_logfile=/dev/null
stdout_logfile=/dev/null
EOF

nginx
supervisord -c /etc/supervisor/supervisord.conf
