FROM teddysun/xray:latest

# Lumipat sa ROOT user para magkaroon ng ganap na kapangyarihan sa pag-install
USER root

# 1. I-install ang Nginx, dependencies, at BASH para sa ligtas na multi-process control
RUN apk update --repository=http://alpinelinux.org && \
    apk add --no-cache nginx ca-certificates curl tzdata bash

# 2. Siguraduhing malinis ang mga loops at gawin ang saktong folders
RUN rm -rf /etc/nginx/http.d/* && \
    mkdir -p /usr/local/openresty/index/html /run/nginx /etc/xray

# 3. Kopyahin ang iyong configuration at interface files
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/local/openresty/index/html/index.html

# 🔥 THE PERMISSION FIX: Ibigay ang pagmamay-ari sa 'nginx' user
RUN chown -R nginx:nginx /usr/local/openresty/index/html /run/nginx && \
    chmod -R 755 /usr/local/openresty/index/html

# 4. I-customize ang pangalan ng process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares && chmod +x /usr/bin/panares

# Set Global Timezone sa UTC para sa mas mabilis at stable na sync sa US servers
ENV TZ=UTC

EXPOSE 8080

# 5. Paggamit ng BASH para sa siguradong error trapping (Kung mamatay ang isa, down ang container para mag-auto restart)
CMD ["/bin/bash", "-c", "panares -config /etc/xray/config.json & NGINX_PID=$!; nginx -g 'daemon off;' || kill $NGINX_PID"]
