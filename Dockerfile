# Base image mula sa teddysun/xray
FROM teddysun/xray:latest

# Gamitin ang root para makapag-install ng extra tools
USER root

# 1. I-install ang nginx, haproxy, at bash
RUN apk update && \
    apk add --no-cache nginx haproxy ca-certificates curl tzdata bash

# 2. Ihanda ang mga folders na kailangan ng Nginx at Xray
RUN mkdir -p /etc/nginx/http.d /usr/share/nginx/html /run/nginx /etc/xray /etc/haproxy && \
    rm -rf /etc/nginx/http.d/* && \
    rm -f /etc/nginx/nginx.conf.default

# 3. Kopyahin ang iyong mga configuration files
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY index.html /usr/share/nginx/html/index.html
COPY start.sh /start.sh

# 4. Permission fix at paggawa ng alias sa panares
RUN chmod +x /start.sh && \
    cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 5. I-expose ang port 8080 (Cloud Run default)
EXPOSE 8080

# 6. Patakbuhin ang start.sh bilang main process
CMD ["/start.sh"]
