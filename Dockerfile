FROM teddysun/xray:latest

USER root

# 1. I-install ang Nginx at mga certificates sa Alpine Linux
RUN apk update && apk add --no-cache nginx ca-certificates

# 2. Burahin ang nakatagong default file ng Alpine para walang kapantay ang routing mo
RUN rm -f /etc/nginx/http.d/default.conf

# 3. Kopyahin ang iyong tatlong mahahalagang file papunta sa container
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

# 4. I-customize ang pangalan ng process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares

EXPOSE 8080

# 🔥 FIXED STARTUP: Inalis ang sysctl tweaks para hindi harangan ng Google Security Layer
CMD ["sh", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
