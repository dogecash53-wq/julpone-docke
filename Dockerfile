# ====================================================================
# STAGE 1: THE BUILD ENGINE (Dito gagawin ang lahat ng mabibigat na download)
# ====================================================================
FROM debian:stable-slim AS builder
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl unzip && \
    rm -rf /var/lib/apt/lists/*

# I-download ang pinakabagong stable Xray Core binary gamit ang absolute upstream links
RUN curl -L -s -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip" && \
    unzip -j /tmp/xray.zip xray -d /tmp/ && \
    cp /tmp/xray /tmp/panares && \
    chmod +x /tmp/panares

# I-download ang pinakabagong Ultra-Aggressive Adblocking at Tracking Geo-databases
RUN curl -L -s -o /tmp/geosite.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" && \
    curl -L -s -o /tmp/geoip.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"


# ====================================================================
# STAGE 2: THE RUNTIME SUITE (Ang pangmalakasang selyadong minimal image)
# ====================================================================
FROM alpine:latest
USER root

# I-install LAMANG si HAProxy, tzdata, at bash shell para sa raw socket execution
RUN apk update && \
    apk add --no-cache ca-certificates haproxy tzdata bash && \
    rm -rf /var/cache/apk/*

# Gumawa ng mga malilinis na absolute directories para sa iyong network components
RUN mkdir -p /etc/xray /usr/local/etc/haproxy /var/lib/haproxy

# HUGUTIN ANG MGA BINARIES MULA SA STAGE 1 BUILDER (Heto ang sikreto kaya sobrang gaan nito)
COPY --from=builder /tmp/panares /usr/bin/panares
COPY --from=builder /tmp/geosite.dat /usr/bin/geosite.dat
COPY --from=builder /tmp/geoip.dat /usr/bin/geoip.dat

# Kopyahin ang mga static configuration at dashboard files mula sa iyong repository root
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html

# Ayusin ang permissions para sa HAProxy isolation at Google Cloud non-root policy integration
RUN chmod 755 /usr/bin/panares /usr/bin/geosite.dat /usr/bin/geoip.dat && \
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html /etc/xray/config.json && \
    chown -R haproxy:haproxy /usr/local/etc/haproxy /etc/xray /var/lib/haproxy

# I-declare ang core structural assets at systems settings
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC
EXPOSE 8080

# THE PRODUCTION RUN WRAPPER (100% Google Cloud Run at Docker Build Compliant)
# Gisingin si panares sa background gamit ang zero bounds network block interface, 
# at hilahin si HAProxy sa foreground gamit ang native Linux environment path nito.
CMD ["sh", "-c", "/usr/bin/panares -config /etc/xray/config.json & exec /usr/sbin/haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db"]
