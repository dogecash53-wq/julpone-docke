FROM teddysun/xray:latest
USER root

# 1. I-update ang package manager at i-install ang HAProxy, bash, at curl
RUN apk update && \
    apk add --no-cache haproxy ca-certificates curl tzdata bash && \
    rm -rf /var/cache/apk/*

# 2. I-rename ang binary file patungong 'panares' base sa iyong signature
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 3. Gumawa ng mga selyadong absolute directories para sa iyong configs
RUN mkdir -p /etc/xray /usr/local/etc/haproxy /var/lib/haproxy

# 4. Kopyahin ang mga configuration files mula sa iyong repository root folder
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html

# 5. I-set ang tamang structural folder ownership at system boundaries
RUN chmod 755 /usr/bin/panares && \
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html /etc/xray/config.json && \
    chown -R haproxy:haproxy /usr/local/etc/haproxy /etc/xray /var/lib/haproxy

ENV TZ=UTC
EXPOSE 8080

# 6. UNTHROTTLED ULTRA-FAST RUN ENGINE (100% Google Cloud Run Compliant)
CMD ["sh", "-c", "/usr/bin/panares -config /etc/xray/config.json & exec /usr/sbin/haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db"]
