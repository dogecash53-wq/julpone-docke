FROM teddysun/xray:latest

# I-install ang Nginx sa loob ng container
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Kopyahin ang iyong mga config files
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf

# I-customize ang pangalan ng executable tulad ng gusto mo
RUN cp /usr/bin/xray /usr/bin/panares

# Buksan ang Port 8080 para sa Cloud Run
EXPOSE 8080

# Pangmalakasang Startup Command: Pinapatakbo ang Nginx sa background at Panares sa foreground
CMD nginx && panares -config /etc/xray/config.json
