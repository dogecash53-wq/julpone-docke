#!/bin/bash

# 1. Siguraduhin na ang Nginx configuration ay gagamit ng tamang port
# I-overwrite ang listen port sa nginx.conf gamit ang $PORT (o 8080)
TARGET_PORT=${PORT:-8080}
sed -i "s/listen 8080/listen $TARGET_PORT/g" /etc/nginx/nginx.conf

# 2. I-start ang Xray sa background (Dapat ay may &)
/usr/bin/panares -config /etc/xray/config.json > /dev/null 2>&1 &

# 3. Start Nginx sa FOREGROUND (Huwag lagyan ng &)
# Ito ang nagpapanatiling buhay sa container para sa Cloud Run
echo "Starting Nginx on port $TARGET_PORT..."
nginx -g 'daemon off;'
