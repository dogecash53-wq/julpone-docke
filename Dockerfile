FROM alpine:latest
USER root

# 1. I-install ang HAProxy, ca-certificates, curl, at extraction tools direkta sa malinis na Alpine
RUN apk update && \
    apk add --no-cache ca-certificates wget unzip tzdata bash curl haproxy && \
    rm -rf /var/cache/apk/*

# 🔄 CACHE BUSTER LAYER: Pinupwersa nitong basagin ang lumang memory ng GitHub Actions
ENV LAST_REPOSITORY_SYNC_DATE=2026-06-23

# 2. I-download ang pinakabagong stable Xray Core binary gamit ang tuwid at absolute upstream link
RUN curl -L -s -o /tmp/xray.zip "https://github.com" && \
    unzip -j /tmp/xray.zip xray -d /usr/bin/ && \
    rm -f /tmp/xray.zip

# 3. I-customize ang binary execution name patungong 'panares' base sa iyong signature
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 4. Mag-inject ng Ultra-Aggressive Adblocking at Tracking Geo-databases gamit ang tamang absolute links
RUN curl -L -s -o /usr/bin/geosite.dat "https://github.com" && \
    curl -L -s -o /usr/bin/geoip.dat "https://github.com"

# Explicitly ideklara ang asset paths para mabasang buo ng 'panares' core ang adblock files mo
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC

# 5. Gumawa ng mga kinakailangang malilinis na direktoryo para sa iyong configs
RUN mkdir -p /etc/xray /usr/local/etc/haproxy /var/lib/haproxy

# 6. Kopyahin ang tatlong natitirang core files mula sa iyong repository root
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html

# 7. Ayusin ang structural folder permissions para sa HAProxy isolation security
RUN chmod 755 /usr/bin/panares /usr/bin/geosite.dat /usr/bin/geoip.dat && \
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html /etc/xray/config.json && \
    chown -R haproxy:haproxy /usr/local/etc/haproxy /etc/xray /var/lib/haproxy

EXPOSE 8080

# 8. THE NATIVE RUN WRAPPER (100% Google Cloud Run at Docker Build Compliant)
CMD ["sh", "-c", "/usr/bin/panares -config /etc/xray/config.json & exec /usr/sbin/haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db"]
