FROM teddysun/xray:latest

# IMPORTANT: Lumipat sa ROOT user para payagan ang pag-install at pag-kopya
USER root

# 1. I-install ang Nginx at mga certificates sa Alpine Linux
RUN apk update && apk add --no-cache nginx ca-certificates

# 2. 🔥 ANG PINAKAFINAL NA DISKARTE: Gumawa ng target OpenResty web directory structure
RUN mkdir -p /usr/local/openresty/nginx/html /run/nginx

# 3. Kopyahin ang iyong configuration at interface pages sa container
COPY config.json /etc/xray/config.json
COPY index.html /usr/local/openresty/nginx/html/index.html

# 4. 🔥 PAPALITAN ANG SYSTEM MAIN CONFIG: Sa halip na i-COPY, direkta nating isusulat
# ang bago mong Nginx routing architecture sa /etc/nginx/nginx.conf ng system.
COPY nginx.conf /etc/nginx/nginx.conf

# 5. I-customize ang pangalan ng process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares

EXPOSE 8080

# 6. Patakbuhin ang panares at panatilihing buhay ang Nginx sa foreground
CMD ["sh", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
