FROM teddysun/xray:latest

USER root

# 1. I-install ang Nginx at linisin ang cache
RUN apk update && apk add --no-cache nginx ca-certificates

# 🔥 THE FORCE FIX: Burahin ang BUONG default config directory ng Nginx 
# para mapilitan itong basahin ang bago mong ginawang configuration nang walang salungat.
RUN rm -rf /etc/nginx/* && mkdir -p /etc/nginx /run/nginx

# 2. Kopyahin ang iyong mga configs at ang webpage dashboard papunta sa container
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/teddysun/nginx/html/index.html

# 3. Palitan ang pangalan ng executable process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares

EXPOSE 8080

# 4. Patakbuhin ang panares at panatilihing buhay ang Nginx sa foreground
CMD ["sh", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
