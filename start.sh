#!/bin/bash
# Start Xray
/usr/bin/panares -config /etc/xray/config.json &

# Start Nginx (Direkta sa 8080)
# Wala nang HAProxy kaya walang port conflict
nginx -g 'daemon off;'
