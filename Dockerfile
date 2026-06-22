FROM haproxy:alpine
USER root

# 1. Install dependencies required for Xray, downloading, and process handling
RUN apk add --no-cache ca-certificates wget unzip tzdata bash curl supervisor

# 2. Download latest stable Xray Core binary - FIXED NATIVE LAYER
RUN wget -qO /tmp/xray.zip https://github.com && \
    unzip -j /tmp/xray.zip xray -d /usr/bin/ && \
    rm -f /tmp/xray.zip

# 3. Rename binary execution variable to 'panares' based on your repository signature
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 4. Inject Ultra-Aggressive Adblocking & Tracking Geo-databases - FIXED NATIVE LAYER
RUN wget -qO /usr/bin/geosite.dat https://github.com && \
    wget -qO /usr/bin/geoip.dat https://github.com

# CRITICAL FIX: Explicitly declare asset paths so Xray core reads the ad-block files flawlessly
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC

# 5. Build absolute configuration directory pathways for your repository execution files
RUN mkdir -p /etc/xray /usr/local/etc/haproxy /var/lib/haproxy

# 6. Copy configuration files and UI dashboard strictly from your repository source
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html
COPY supervisord.conf /etc/supervisord.conf

# 7. Secure absolute structural folder permissions for internal system runtime
RUN chmod 755 /usr/bin/panares /usr/bin/geosite.dat /usr/bin/geoip.dat && \
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html /etc/xray/config.json /etc/supervisord.conf && \
    chown -R haproxy:haproxy /usr/local/etc/haproxy /etc/xray /var/lib/haproxy

EXPOSE 8080

# 8. FIXED ALPINE EXECUTION PATH
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
