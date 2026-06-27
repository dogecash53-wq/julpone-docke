#!/bin/sh

# 1. Start Xray/Panares sa background
/usr/bin/panares -config /etc/xray/config.json > /dev/null 2>&1 &
echo "Xray started..."
sleep 3

# 2. Start HAProxy sa background
haproxy -f /etc/haproxy/haproxy.cfg -D
echo "HAProxy started..."
sleep 2

# 3. Start Nginx sa foreground (HULI ITO!)
echo "Starting Nginx..."
nginx -g "daemon off;"
