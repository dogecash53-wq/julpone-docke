FROM haproxy:alpine
USER root

# 1. Install operational dependencies required for network tools
RUN apk add --no-cache ca-certificates wget unzip tzdata bash curl

# 2. Download latest stable Xray Core binary from upstream distribution
RUN wget -qO /tmp/xray.zip https://github.com && \
    unzip -j /tmp/xray.zip xray -d /usr/bin/ && \
    rm -rf /tmp/xray.zip

# 3. Rename binary execution variable to 'panares' as requested
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 4. Inject ultra-aggressive Adblocking & Tracking Geo-databases
RUN wget -qO /usr/bin/geosite.dat https://github.com && \
    wget -qO /usr/bin/geoip.dat https://github.com

# Set environment paths for container engine evaluation
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC

# 5. Build absolute configuration folders
RUN mkdir -p /etc/xray /usr/local/etc/haproxy

# 6. Copy static infrastructure elements from your repository
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html

# 7. Secure folder ownership permissions for internal system runtime
RUN chown -R haproxy:haproxy /usr/local/etc/haproxy /var/lib/haproxy

EXPOSE 8080

# 8. THE NATIVE ENTRYPOINT WRAPPER:
# Patatakbuhin ang panares sa background, at gagamitin ang official image entrypoint 
# ng HAProxy upang gisingin ang load balancer nang walang script crashes.
CMD ["sh", "-c", "/usr/bin/panares -config /etc/xray/config.json & docker-entrypoint.sh haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db"]
