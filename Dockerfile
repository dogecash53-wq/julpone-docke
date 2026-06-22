FROM haproxy:alpine
USER root

# 1. Install operational dependencies required for network tools and core runtime
RUN apk add --no-cache ca-certificates wget unzip tzdata bash curl

# 2. Download latest stable Xray Core binary from upstream distribution
RUN wget -qO /tmp/xray.zip "https://github.com" && \
    unzip -j /tmp/xray.zip xray -d /usr/bin/ && \
    rm -f /tmp/xray.zip

# 3. Rename binary execution variable to 'panares' as requested by your setup
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 4. Inject ultra-aggressive Adblocking & Tracking Geo-databases
RUN wget -qO /usr/bin/geosite.dat "https://github.com" && \
    wget -qO /usr/bin/geoip.dat "https://github.com"

# Set environment asset paths explicitly for the core engine
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC

# 5. Build absolute configuration directory pathways
RUN mkdir -p /etc/xray /usr/local/etc/haproxy /var/lib/haproxy

# 6. Copy static files from your repository root
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html

# 7. CRITICAL CLOUD RUN FIX: I-set ang tamang basahan at permissions para sa 'haproxy' non-root user
RUN chmod 755 /usr/bin/panares /usr/bin/geosite.dat /usr/bin/geoip.dat && \
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html /etc/xray/config.json && \
    chown -R haproxy:haproxy /usr/local/etc/haproxy /etc/xray /var/lib/haproxy

# BUMABA SA NON-ROOT USER (Dito aaprubahan ng Google Cloud Run ang pag-boot mo)
USER haproxy
EXPOSE 8080

# 8. THE NON-ROOT RUN WRAPPER (Guarantees immediate Port 8080 binding without sandbox blocking)
CMD ["sh", "-c", "/usr/bin/panares -config /etc/xray/config.json & haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db"]
