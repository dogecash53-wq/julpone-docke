FROM teddysun/panares:latest
COPY config.json /etc/xray/config.json
EXPOSE 8080
CMD ["panares", "-config", "/etc/xray/config.json"]
