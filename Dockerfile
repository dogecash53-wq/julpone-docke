FROM teddysun/xray:latest
USER root

# I-install ang nginx at HAPROXY
RUN apk update && \
    apk add --no-cache nginx haproxy ca-certificates curl tzdata bash

RUN mkdir -p /etc/nginx/http.d /usr/local/openresty/index/html /run/nginx /etc/xray && \
    rm -rf /etc/nginx/http.d/*

COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY index.html /usr/local/openresty/index/html/index.html
COPY start.sh /start.sh

RUN chmod +x /start.sh && \
    cp /usr/bin/xray /usr/bin/panares

EXPOSE 8080
CMD ["/bin/bash", "/start.sh"]
