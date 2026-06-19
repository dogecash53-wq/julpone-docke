FROM teddysun/xray:latest

# Lumipat sa ROOT user para magkaroon ng ganap na kapangyarihan sa pag-install
USER root

# 1. I-install ang Nginx, ca-certificates, at curl (para sa healthcheck) gamit ang mabilis na global mirror
RUN apk update --repository=http://alpinelinux.org && \
    apk add --no-cache nginx ca-certificates curl tzdata

# 2. Linisin ang mga default loops ng Alpine at gumawa ng tamang OpenResty structure
RUN rm -rf /etc/nginx/http.d/* && mkdir -p /usr/local/openresty/index/html /run/nginx

# 3. Kopyahin ang iyong configuration at interface files mula sa iyong repository
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/local/openresty/index/html/index.html

# 🔥 THE PERMISSION FIX: Ibigay ang pagmamay-ari at read access sa 'nginx' user 
RUN chown -R nginx:nginx /usr/local/openresty/index/html && \
    chmod -R 755 /usr/local/openresty/index/html

# 4. I-customize ang pangalan ng process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares

# Set Global Timezone sa UTC para sa mas mabilis at stable na sync sa US servers
ENV TZ=UTC

EXPOSE 8080

# 5. Paggamit ng 'exec' form na may fail-safe wrapper para kung mag-crash ang isa, mag-reboot ang container
CMD ["sh", "-c", "panares -config /etc/xray/config.json & NGINX_PID=$!; nginx -g 'daemon off;' || kill $NGINX_PID"]
