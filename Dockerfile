FROM haproxy:alpine
USER root

# 1. I-install ang mga kailangang dependencies para sa Xray, downloading, at process handling
RUN apk add --no-cache ca-certificates wget unzip tzdata bash curl

# 2. I-download ang pinakabagong stable Xray Core binary mula sa official repository
RUN wget -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -j /tmp/xray.zip xray -d /usr/bin/ && \
    rm -rf /tmp/xray.zip

# 3. I-customize ang binary execution name patungong 'panares' base sa luma mong setup
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 4. Mag-inject ng Ultra-Aggressive Adblocking, Tracking, at Anti-Adult Geo-databases (Gagana na ang DNS blocklist mo!)
RUN wget -qO /usr/bin/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat && \
    wget -qO /usr/bin/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

# CRITICAL FIX: I-declare ang asset paths para mabasang buo ng 'panares' core ang adblock files mo
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC

# 5. Gumawa ng mga kinakailangang malilinis na direktoryo para sa iyong configs
RUN mkdir -p /etc/xray /etc/haproxy

# 6. Kopyahin ang tatlong natitirang core files mula sa iyong repository root (Wala na si Nginx)
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY index.html /etc/haproxy/index.html

# 7. Ayusin ang structural ownership at permissions para sa HAProxy isolation security
RUN chown -R haproxy:haproxy /etc/haproxy /var/lib/haproxy

EXPOSE 8080

# 8. Ultra-Fast High-Performance Multi-Process Monitor Loop (Selyado laban sa Zombie Process Crash)
CMD ["/bin/bash", "-c", "\
    echo '🚀 Starting JULPONE HAPROXY-RAW L4 Core System...'; \
    /usr/bin/panares -config /etc/xray/config.json & \
    PID_XRAY=$!; \
    /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -db & \
    PID_HAPROXY=$!; \
    echo '✅ Core engines successfully binding to Layer 4. Monitoring...'; \
    while true; do \
        kill -0 $PID_XRAY 2>/dev/null || { echo '❌ Xray (panares) failed! Exiting...'; exit 1; }; \
        kill -0 $PID_HAPROXY 2>/dev/null || { echo '❌ HAProxy failed! Exiting...'; exit 1; }; \
        sleep 5; \
    done \
"]
