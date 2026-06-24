#!/bin/bash

# 1. Awtomatikong palitan ang listen 8080 ng Nginx tungong 8081
sed -i 's/listen 8080/listen 8081/g' /etc/nginx/nginx.conf

# 2. I-start ang Xray (panares)
/usr/bin/panares -config /etc/xray/config.json &

# 3. I-start ang Nginx sa background
nginx -g 'daemon off;' &

# 4. I-start ang HAProxy (ang magsisilbing gateway sa 8080)
haproxy -f /etc/haproxy/haproxy.cfg -db
