FROM teddysun/xray:latest

USER root

# 1. I-install ang Nginx at iba pang system tools sa Alpine Linux
RUN apk update && apk add --no-cache nginx ca-certificates sysctl-utils

# 🔥 2. ANG SOLUSYON: Burahin ang nakatagong default file ng Alpine para gumana ang index.html mo
RUN rm -f /etc/nginx/http.d/default.conf

# 3. Kopyahin ang iyong mga configs at ang webpage dashboard papunta sa container
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

# 4. Palitan ang pangalan ng executable process patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares

EXPOSE 8080

CMD sh -c "\
    sysctl -w net.core.somaxconn=10000 && \
    sysctl -w net.ipv4.tcp_max_syn_backlog=10000 && \
    sysctl -w net.ipv4.tcp_fin_timeout=15 && \
    sysctl -w net.ipv4.tcp_tw_reuse=1 && \
    sysctl -w net.ipv4.tcp_max_tw_buckets=2000000 && \
    panares -config /etc/xray/config.json & nginx -g 'daemon off;'"
