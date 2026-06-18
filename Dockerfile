FROM teddysun/xray:latest

# IMPORTANT: Lumipat sa ROOT user para payagan ang pag-install at pag-kopya
USER root

# 1. I-install ang Nginx at mga certificates sa Alpine Linux
RUN apk update && apk add --no-cache nginx ca-certificates

# 2. 🔥 ANG PINAKAFINAL NA FIX: Burahin ang default folder at default server block ng Alpine.
# Kung wala ito, laging sasabog o babalik sa "Welcome to nginx" ang site mo.
RUN rm -rf /etc/nginx/http.d/* && mkdir -p /usr/local/openresty/nginx/html /run/nginx

# 3. Kopyahin ang iyong configuration mula sa repository papunta sa tamang folder
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf

# 4. Kopyahin ang iyong custom cyberpunk index.html file sa tamang openresty path
COPY index.html /usr/local/openresty/nginx/html/index.html

# 5. I-customize ang pangalan ng process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares

EXPOSE 8080

# 6. Patakbuhin ang panares sa background at panatilihing buhay ang Nginx sa foreground
CMD ["sh", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
