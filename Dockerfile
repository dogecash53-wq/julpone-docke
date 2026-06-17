FROM teddysun/xray:latest

# Alpine Linux ang base image nito, kaya 'apk' ang tamang package manager
RUN apk update && apk add --no-cache nginx ca-certificates

# Kopyahin ang iyong mga config files
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf

# I-customize ang pangalan ng executable patungong 'panares'
RUN cp /usr/bin/xray /usr/bin/panares

# Buksan ang Port 8080 para sa Cloud Run
EXPOSE 8080

# Pangmalakasang Startup Command: Pinapatakbo ang panares sa background,
# habang ang Nginx ay pinapanatiling buhay sa foreground gamit ang 'daemon off;'
CMD ["sh", "-c", "panares -config /etc/xray/config.json & nginx -g 'daemon off;'"]
