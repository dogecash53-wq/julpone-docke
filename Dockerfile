FROM teddysun/xray:latest
USER root
RUN apk update && apk add --no-cache nginx bash
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh && cp /usr/bin/xray /usr/bin/panares
EXPOSE 8080
CMD ["/start.sh"]
