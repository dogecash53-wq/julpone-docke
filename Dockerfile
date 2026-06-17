FROM teddysun/xray:latest

USER root

# Install Nginx, certificates, and system configuration tools
RUN apk update && apk add --no-cache nginx ca-certificates sysctl-utils

COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf

# Rename executable
RUN cp /usr/bin/xray /usr/bin/panares

# Open Port 8080
EXPOSE 8080

# Pangmalakasang Startup with Advanced Kernel TCP Tweaks for high-concurrency tunneling
CMD sh -c "\
    sysctl -w net.core.somaxconn=10000 && \
    sysctl -w net.ipv4.tcp_max_syn_backlog=10000 && \
    sysctl -w net.ipv4.tcp_fin_timeout=15 && \
    sysctl -w net.ipv4.tcp_tw_reuse=1 && \
    sysctl -w net.ipv4.tcp_max_tw_buckets=2000000 && \
    panares -config /etc/xray/config.json & nginx -g 'daemon off;'"
