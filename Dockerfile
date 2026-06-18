FROM teddysun/xray:latest

# IMPORTANT: Lumipat sa ROOT user para payagan ang pag-install at pag-kopya
USER root

# I-install ang Nginx at mga kinakailangang certificates sa Alpine Linux
RUN apk update && apk add --no-cache nginx ca-certificates

# 🔥 ANG PINAKAFINAL NA FIX: Burahin ang LAHAT ng factory configurations ng Nginx 
# (Parehong ang nginx.conf at ang http.d folder) para mapilitan itong basahin ang file mo LANG.
RUN rm -rf /etc/nginx/http.d/* && rm -f /etc/nginx/nginx.conf && mkdir -p /usr/local/openresty/nginx/html /run/nginx

# Kopyahin ang iyong config.json at ang malinis na nginx.conf sa kanilang tamang direktoryo
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf

# Kopyahin ang iyong custom cyberpunk index.html file sa tamang folder
COPY index.html /usr/local/openresty/nginx/html/index.html

# I-customize ang pangalan ng executable patungong 'panares' nang walang permission error
RUN cp /usr/bin/xray /usr/bin/panares

# Buksan ang Port 8080 para sa Cloud Run
EXPOSE 8080

# Patakbuhin ang panares at panatilihing buhay ang Nginx sa foreground
CMD ["sh", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
