FROM teddysun/xray:latest

# Lumipat sa ROOT user para magkaroon ng ganap na kapangyarihan sa pag-install
USER root

# 1. I-install ang Nginx at mga certificates sa Alpine Linux
RUN apk update && apk add --no-cache nginx ca-certificates

# 2. Linisin ang mga default loops ng Alpine at gumawa ng tamang OpenResty structure
RUN rm -rf /etc/nginx/http.d/* && mkdir -p /usr/local/openresty/nginx/html /run/nginx

# 3. Kopyahin ang iyong configuration at interface files mula sa iyong repository
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/local/openresty/nginx/html/index.html

# 🔥 THE PERMISSION FIX: Ibigay ang pagmamay-ari at read access sa 'nginx' user 
# para hindi ka mag-404 o ma-bypass ng default welcome rules.
RUN chown -R nginx:nginx /usr/local/openresty/nginx/html && \
    chmod -R 755 /usr/local/openresty/nginx/html

# 4. I-customize ang pangalan ng process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares

EXPOSE 8080

# 5. Patakbuhin ang panares sa background habang pinapanatiling buhay ang Nginx sa foreground
CMD ["sh", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
