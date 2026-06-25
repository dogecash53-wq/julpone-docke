FROM teddysun/xray:latest
USER root

# 1. Install dependencies
RUN apk update && apk add --no-cache nginx bash

# 2. Copy files (Siguraduhing nasa folder mo ang mga ito)
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/local/openresty/index/html/index.html

# 3. Setup folders and permissions
RUN mkdir -p /run/nginx /etc/xray && \
    cp /usr/bin/xray /usr/bin/panares && chmod +x /usr/bin/panares && \
    chown -R nginx:nginx /usr/local/openresty/index/html /run/nginx /etc/nginx

# 4. Ang "Auto-Tune" at Start script (Pinagsama na natin dito)
RUN echo '#!/bin/bash' > /start.sh && \
    echo '# Optimization part' >> /start.sh && \
    echo 'sed -i "s/worker_connections 1024;/worker_connections 8192;/g" /etc/nginx/nginx.conf' >> /start.sh && \
    echo 'sed -i "s/sendfile on;/sendfile on; tcp_nopush on; tcp_nodelay on;/g" /etc/nginx/nginx.conf' >> /start.sh && \
    echo '# Start Xray' >> /start.sh && \
    echo '/usr/bin/panares -config /etc/xray/config.json &' >> /start.sh && \
    echo '# Start Nginx' >> /start.sh && \
    echo 'nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
