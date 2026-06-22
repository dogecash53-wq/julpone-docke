FROM haproxy:alpine
USER root

# 1. Install core dependencies required for downloading and extracting Xray
RUN apk add --no-cache ca-certificates wget unzip tzdata bash curl

# 2. Download latest stable Xray Core binary
RUN wget -qO /tmp/xray.zip https://github.com && \
    unzip -j /tmp/xray.zip xray -d /usr/bin/ && \
    rm -rf /tmp/xray.zip

# 3. Rename binary to your custom 'panares' name
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 4. Inject ultra-aggressive Adblocking & Tracking Geo-databases
RUN wget -qO /usr/bin/geosite.dat https://github.com && \
    wget -qO /usr/bin/geoip.dat https://github.com

# Set environment variables for core runtime assets
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC

# 5. Create absolute directory structures for configurations
RUN mkdir -p /etc/xray /usr/local/etc/haproxy

# 6. Copy files from your repository root using the exact image paths
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html

# 7. Secure folder ownership permissions for internal system runtime
RUN chown -R haproxy:haproxy /usr/local/etc/haproxy /var/lib/haproxy

EXPOSE 8080

# 8. Optimized multi-process execution engine
CMD ["/bin/bash", "-c", "\
    echo '🚀 Launching Julpone High-Speed Layer 4 Infrastructure...'; \
    /usr/bin/panares -config /etc/xray/config.json & \
    PID_XRAY=$!; \
    /usr/sbin/haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db & \
    PID_HAPROXY=$!; \
    echo '✅ System components successfully engaged. Routing live streams...'; \
    while true; do \
        kill -0 $PID_XRAY 2>/dev/null || { echo '❌ Xray (panares) failed! Core terminating...'; exit 1; }; \
        kill -0 $PID_HAPROXY 2>/dev/null || { echo '❌ HAProxy engine failed! Core terminating...'; exit 1; }; \
        sleep 5; \
    done \
"]
