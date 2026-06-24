FROM teddysun/xray:latest

# Gamitin ang apt-get para sa Debian base ng teddysun/xray
RUN apt-get update && apt-get install -y \
    nginx \
    bash \
    && rm -rf /var/lib/apt/lists/*

# I-copy ang files
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh

# Permission fix: gawing executable ang start.sh
RUN chmod +x /start.sh && \
    # Siguraduhin na ang panares ay nasa tamang path
    cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# Cloud Run requirement: ang Nginx ay kailangang makapagsulat sa /tmp
RUN mkdir -p /tmp/nginx_client_body && \
    chown -R nginx:nginx /tmp/nginx_client_body /var/lib/nginx /var/log/nginx

EXPOSE 8080

CMD ["/start.sh"]
