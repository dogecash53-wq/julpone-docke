FROM teddysun/panares:latest
COPY config.json /etc/panares/config.json
EXPOSE 8080
CMD ["panares", "-config", "/etc/panares/config.json"]
