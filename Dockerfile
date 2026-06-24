FROM teddysun/xray:latest
USER root
RUN apk update && apk add --no-cache nginx bash
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/local/openresty/index/html/index.html
RUN mkdir -p /run/nginx /etc/xray
RUN cp /usr/bin/xray /usr/bin/panares && chmod +x /usr/bin/panares

# Startup script
RUN echo -e '#!/bin/bash\n\
/usr/bin/panares -config /etc/xray/config.json &\n\
nginx -g "daemon off;"' > /start.sh && chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
