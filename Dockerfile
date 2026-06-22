FROM ubuntu:latest
USER root

# 1. Pigilan ang mga interactive prompts at i-install ang HAProxy at core utility tools
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates wget unzip tzdata bash curl haproxy && \
    rm -rf /var/lib/apt/lists/*

# 2. I-download ang pinakabagong stable Xray Core binary gamit ang absolute upstream link
RUN curl -L -s -o /tmp/xray.zip "https://github.com" && \
    unzip -j /tmp/xray.zip xray -d /usr/bin/ && \
    rm -f /tmp/xray.zip

# 3. I-rename ang binary execution process patungong 'panares' base sa iyong signature
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 4. Mag-inject ng Ultra-Aggressive Adblocking at Tracking Geo-databases
RUN curl -L -s -o /usr/bin/geosite.dat "https://github.com" && \
    curl -L -s -o /usr/bin/geoip.dat "https://github.com"

# I-declare ang asset paths para mabasang buo ng 'panares' core ang adblock files mo
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC

# 5. Gumawa ng mga kinakailangang malilinis na direktoryo para sa iyong configs
RUN mkdir -p /etc/xray /usr/local/etc/haproxy /var/lib/haproxy

# 6. Kopyahin ang tatlong natitirang core files mula sa iyong repository root
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html

# 7. Ayusin ang structural folder permissions para sa HAProxy isolation security sa Ubuntu environment
RUN chmod 755 /usr/bin/panares /usr/bin/geosite.dat /usr/bin/geoip.dat && \
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html /etc/xray/config.json && \
    chown -R haproxy:haproxy /usr/local/etc/haproxy /etc/xray /var/lib/haproxy

EXPOSE 8080

# 8. THE NATIVE RUN WRAPPER (100% Google Cloud Run at Docker Build Compliant)
# Gisingin ang panares sa background, at gamitin ang default Ubuntu HAProxy path 
# sa foreground upang awtomatikong mag-bind sa port 8080 nang walang kahit anong system block.
CMD ["sh", "-c", "/usr/bin/panares -config /etc/xray/config.json & exec /usr/sbin/haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db"]
