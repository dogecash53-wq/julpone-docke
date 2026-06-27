#!/bin/sh
# Start Panares (Xray)
/usr/bin/panares -config /etc/xray/config.json > /dev/null 2>&1 &
sleep 2

# Start HAProxy
haproxy -f /etc/haproxy/haproxy.cfg -D
sleep 2

# Start Nginx (Frontend)
nginx -g "daemon off;"
