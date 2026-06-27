#!/bin/sh
# Start Xray sa background
/usr/bin/panares -config /etc/xray/config.json > /dev/null 2>&1 &

# Start Nginx sa foreground
nginx -g "daemon off;"
