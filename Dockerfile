FROM teddysun/xray:latest

# Lumipat sa ROOT user para magkaroon ng ganap na kapangyarihan sa pag-install
USER root

# 1. I-install ang Nginx at standard packages (Inalis ang custom mirror list para hindi mag-fail)
RUN apk update && apk add --no-cache nginx ca-certificates curl tzdata bash

# 2. Ligtas na paggawa ng directories gamit ang anti-crash flags
RUN mkdir -p /etc/nginx/http.d /usr/local/openresty/index/html /run/nginx /etc/xray && \
    rm -rf /etc/nginx/http.d/*

# 3. Kopyahin ang mga configuration files mula sa iyong code repository
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/local/openresty/index/html/index.html

# 🔥 PERMISSION CORRECTION: Siguraduhing may karapatan ang nginx user sa socket at data folders
RUN chown -R nginx:nginx /usr/local/openresty/index/html /run/nginx /etc/nginx && \
    chmod -R 755 /usr/local/openresty/index/html

# 4. I-customize ang pangalan ng process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares && chmod +x /usr/bin/panares

ENV TZ=UTC
EXPOSE 8080

# 5. Nilinis ang process manager string execution to pass standard validation formats
CMD ["/bin/bash", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
