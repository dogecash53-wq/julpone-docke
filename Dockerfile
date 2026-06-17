FROM teddysun/xray:latest

USER root

# 1. I-install ang Nginx at mga kinakailangang certificates
RUN apk update && apk add --no-cache nginx ca-certificates

# 2. Siguraduhing may tamang folder para sa runtime pid ng Nginx
RUN mkdir -p /run/nginx

# 3. Kopyahin ang iyong mga configs at ang webpage dashboard papunta sa container
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

# 4. Palitan ang pangalan ng executable process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares

EXPOSE 8080

# 5. Patakbuhin ang panares at panatilihing buhay ang Nginx sa foreground
CMD ["sh", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
