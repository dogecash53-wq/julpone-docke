FROM teddysun/xray:latest

# IMPORTANT: Lumipat sa ROOT user para payagan ang pag-install at pag-kopya
USER root

# I-install ang Nginx at mga kinakailangang certificates sa Alpine Linux
RUN apk update && apk add --no-cache nginx ca-certificates

# 🔥 DIREKTANG FIX: Burahin ang default file ng Alpine at gumawa ng OpenResty paths para sa index.html mo
RUN rm -f /etc/nginx/http.d/default.conf && mkdir -p /usr/local/openresty/nginx/html /run/nginx

# Kopyahin ang iyong config.json at nginx.conf sa kanilang tamang direktoryo
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf

# 🔥 DIREKTANG FIX: Kopyahin ang index.html mo papunta sa folder na binabasa ng nginx.conf mo ngayon
COPY index.html /usr/local/openresty/nginx/html/index.html

# I-customize ang pangalan ng executable patungong 'panares' nang walang permission error
RUN cp /usr/bin/xray /usr/bin/panares

# Buksan ang Port 8080 para sa Cloud Run
EXPOSE 8080

# Patakbuhin ang panares at panatilihing buhay ang Nginx sa foreground
CMD ["sh", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
