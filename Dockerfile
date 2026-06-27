# Base image mula sa teddysun/xray
FROM teddysun/xray:latest

# Gamitin ang root para makapag-install ng extra tools
USER root

# 1. I-install ang nginx at bash lamang (inuna na ang nginx)
RUN apk update && \
    apk add --no-cache nginx bash ca-certificates curl tzdata

# 2. Ihanda ang mga folders at linisin ang default configs
RUN mkdir -p /etc/nginx/http.d /usr/share/nginx/html /run/nginx /etc/xray && \
    rm -rf /etc/nginx/http.d/* && \
    rm -f /etc/nginx/nginx.conf.default

# 3. Kopyahin ang iyong configuration files
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
COPY start.sh /start.sh

# 4. Permission fix
RUN chmod 644 /usr/share/nginx/html/index.html
RUN chmod +x /start.sh && \
    cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 5. I-expose ang port 8080 (Cloud Run default)
EXPOSE 8080

# 6. Patakbuhin ang start.sh bilang main process
CMD ["/start.sh"]
