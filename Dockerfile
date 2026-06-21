FROM teddysun/xray:latest

USER root

# I-install ang Nginx, HAProxy, at dependencies
RUN apk update && \
    apk add --no-cache nginx haproxy ca-certificates curl tzdata bash

# Gawa ng mga kinakailangang direktoryo
RUN mkdir -p /etc/nginx/http.d /usr/local/openresty/index/html /run/nginx /etc/xray /etc/haproxy && \
    rm -rf /etc/nginx/http.d/*

# Kopyahin ang apat na files mula sa repo mo
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/local/openresty/index/html/index.html
COPY haproxy.cfg /etc/haproxy/haproxy.cfg

# Permission fixes
RUN chown -R nginx:nginx /usr/local/openresty/index/html /run/nginx /etc/nginx && \
    chown -R haproxy:haproxy /etc/haproxy && \
    chmod -R 755 /usr/local/openresty/index/html

# I-customize ang pangalan ng process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares && chmod +x /usr/bin/panares

ENV TZ=UTC
EXPOSE 8080

# Patakbuhin ang Xray, Nginx, at HAProxy nang sabay-sabay
CMD ["/bin/bash", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;' & haproxy -f /etc/haproxy/haproxy.cfg -db"]
