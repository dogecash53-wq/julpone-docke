FROM teddysun/xray:latest

# Gamitin ang -y para sa apt-get at siguraduhing hindi ito hihingi ng input
# Idinagdag ang 'curl' at 'procps' para sa mas maayos na process monitoring
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx bash procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# I-copy ang configuration files
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh

# Siguraduhin ang tamang permissions at symlink
RUN chmod +x /start.sh && \
    ln -sf /usr/bin/xray /usr/bin/panares && \
    mkdir -p /var/lib/nginx/tmp /var/log/nginx && \
    chown -R www-data:www-data /var/lib/nginx /var/log/nginx

EXPOSE 8080

CMD ["/start.sh"]
