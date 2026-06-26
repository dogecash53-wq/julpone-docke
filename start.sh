#!/bin/bash

# 1. Start Xray (Panares)
/usr/bin/panares -config /etc/xray/config.json > /dev/null 2>&1 &

# 2. Start HAProxy
# -f ay path ng config, -D ay para sa daemon mode
haproxy -f /etc/haproxy/haproxy.cfg -D

# 3. Start Nginx
nginx -g "daemon off;"
