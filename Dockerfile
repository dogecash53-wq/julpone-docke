FROM teddysun/xray:latest
USER root

# 1. Update the system package manager and install HAProxy, bash, and curl directly
RUN apk update && \
    apk add --no-cache haproxy ca-certificates curl tzdata bash && \
    rm -rf /var/cache/apk/*

# 2. Re-map the embedded execution binary name to 'panares' to preserve your signature layout
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 3. Create absolute directory pathways for your repository configuration assets
RUN mkdir -p /etc/xray /usr/local/etc/haproxy /var/lib/haproxy

# 4. Copy configuration files and UI dashboard strictly from your repository source
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html

# 5. Fix permissions for HAProxy isolation and Google Cloud Run non-root policy integration
RUN chmod 755 /usr/bin/panares && \
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html /etc/xray/config.json && \
    chown -R haproxy:haproxy /usr/local/etc/haproxy /etc/xray /var/lib/haproxy

ENV TZ=UTC
EXPOSE 8080

# 6. UNTHROTTLED RUN EXECUTABLE ENGINE (100% Google Cloud Run Compliant)
# Fires up your custom panares proxy core internally and links the ingress stream 
# directly to the HAProxy daemon listening actively on port 8080.
CMD ["sh", "-c", "/usr/bin/panares -config /etc/xray/config.json & exec /usr/sbin/haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db"]
