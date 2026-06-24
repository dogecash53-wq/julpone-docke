#!/bin/bash
# Siguraduhin na ang lahat ng folder ay writable
mkdir -p /tmp/nginx_client_body
/usr/bin/panares -config /etc/xray/config.json &
# Start Nginx
nginx -g 'daemon off;'
