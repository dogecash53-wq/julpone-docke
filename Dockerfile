FROM teddysun/xray:latest

# Lumipat sa ROOT user para magkaroon ng ganap na kapangyarihan sa pag-install
USER root

# 1. I-install ang Nginx at mga pangunahing dependencies nang ligtas (Inalis ang sirang repo path)
RUN apk update && \
    apk add --no-cache nginx ca-certificates curl tzdata bash

# 2. Ligtas na paggawa ng mga kinakailangang direktoryo
RUN mkdir -p /etc/nginx/http.d /usr/local/openresty/index/html /run/nginx /etc/xray && \
    rm -rf /etc/nginx/http.d/*

# 3. Kopyahin ang iyong configuration at interface files mula sa repository root
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/local/openresty/index/html/index.html

# 🔥 PERMISSION FIX: Ibigay ang pagmamay-ari at saktong permisyon sa 'nginx' user
RUN chown -R nginx:nginx /usr/local/openresty/index/html /run/nginx /etc/nginx && \
    chmod -R 755 /usr/local/openresty/index/html

# 4. I-customize ang pangalan ng process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares && chmod +x /usr/bin/panares

ENV TZ=UTC
EXPOSE 8080

# 5. Patakbuhin ang panares at nginx gamit ang bash string execution
CMD ["/bin/bash", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
