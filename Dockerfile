FROM teddysun/xray:latest

COPY config.json /etc/xray/config.json

# Palitan ang pangalan ng 'xray' executable patungong 'panares-freenet'
RUN cp /usr/bin/xray /usr/bin/panares-freenet

# Buksan ang port 8080
EXPOSE 8080

# Patakbuhin ang app gamit ang bagong pangalan na 'panares'
CMD ["panares-freenet", "-config", "/etc/xray/config.json"]

