FROM haproxy:alpine
USER root

# 1. Install critical dependencies and Supervisor package manager
RUN apk add --no-cache ca-certificates wget unzip tzdata bash curl supervisor

# 2. Download latest stable Xray Core binary from upstream distribution
RUN wget -qO /tmp/xray.zip "https://github.com" && \
    unzip -j /tmp/xray.zip xray -d /usr/bin/ && \
    rm -f /tmp/xray.zip

# 3. Rename binary execution variable to 'panares' as requested
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 4. Inject ultra-aggressive Adblocking & Tracking Geo-databases
RUN wget -qO /usr/bin/geosite.dat "https://github.com" && \
    wget -qO /usr/bin/geoip.dat "https://github.com"

# Set environment asset paths explicitly for the core engine
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC

# 5. Build absolute configuration directory pathways
RUN mkdir -p /etc/xray /usr/local/etc/haproxy /var/lib/haproxy /etc/supervisor.d

# 6. Copy files from your repository root
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html
COPY supervisord.conf /etc/supervisord.conf

# 7. Secure execution rights and folder ownership configurations
RUN chmod 755 /usr/bin/panares /usr/bin/geosite.dat /usr/bin/geoip.dat && \
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html /etc/xray/config.json /etc/supervisord.conf && \
    chown -R haproxy:haproxy /usr/local/etc/haproxy /etc/xray /var/lib/haproxy

EXPOSE 8080

# 8. Trigger clean boot sequence using Supervisor in the foreground
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
