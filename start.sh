#!/bin/bash

# Palitan ang port sa haproxy config bago i-start gamit ang $PORT variable
sed -i "s/8080/$PORT/g" /etc/haproxy/haproxy.cfg
haproxy -f /etc/haproxy/haproxy.cfg -db

# 2. I-start ang Xray (panares)
/usr/bin/panares -config /etc/xray/config.json &

# 3. I-start ang Nginx sa background
nginx -g 'daemon off;' &

# 4. I-start ang HAProxy (ang magsisilbing gateway sa 8080)
haproxy -f /etc/haproxy/haproxy.cfg -db
