#!/bin/bash
# auto-tune.sh - Optimization script

# Optimization para sa Nginx
sed -i 's/worker_connections 1024;/worker_connections 8192;/' /etc/nginx/nginx.conf
sed -i 's/sendfile on;/sendfile on; tcp_nopush on; tcp_nodelay on;/' /etc/nginx/nginx.conf

# Optimization para sa Xray (MUX)
# In-inject natin ang mux sa loob ng config.json
if ! grep -q "mux" /etc/xray/config.json; then
    sed -i '/"outbounds": \[/a \    "mux": { "enabled": true, "concurrency": 8 },' /etc/xray/config.json
fi
