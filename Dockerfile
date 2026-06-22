FROM haproxy:alpine
USER root

# 1. I-install ang mga kailangang dependencies para sa Xray, downloading, at process handling
RUN apk add --no-cache ca-certificates wget unzip tzdata bash curl

# 2. I-download ang pinakabagong stable Xray Core binary mula sa official repository
RUN wget -qO /tmp/xray.zip https://github.com && \
    unzip -j /tmp/xray.zip xray -d /usr/bin/ && \
    rm -rf /tmp/xray.zip

# 3. I-customize ang binary execution name patungong 'panares' base sa luma mong setup
RUN cp /usr/bin/xray /usr/bin/panares && \
    chmod +x /usr/bin/panares

# 4. Mag-inject ng Ultra-Aggressive Adblocking, Tracking, at Anti-Adult Geo-databases
RUN wget -qO /usr/bin/geosite.dat https://github.com && \
    wget -qO /usr/bin/geoip.dat https://github.com

# I-declare ang asset paths para mabasang buo ng 'panares' core ang adblock files mo
ENV XRAY_LOCATION_ASSET=/usr/bin
ENV TZ=UTC

# 5. Gumawa ng mga kinakailangang malilinis na direktoryo para sa iyong configs
RUN mkdir -p /etc/xray /etc/haproxy

# 6. Kopyahin ang tatlong natitirang core files mula sa iyong repository root
COPY config.json /etc/xray/config.json
COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY index.html /etc/haproxy/index.html

# 7. Ayusin ang structural ownership at permissions para sa HAProxy isolation security
RUN chown -R haproxy:haproxy /etc/haproxy /var/lib/haproxy

EXPOSE 8080

# 8. FIXED CMD ENGINE: Patakbuhin ang panares sa background at hilahin ang HAProxy sa foreground gamit ang exec.
# Ito ang nagpapakita sa Cloud Run na aktibong nakikinig ang port 8080 nang walang delay.
CMD /usr/bin/panares -config /etc/xray/config.json & exec /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -db
