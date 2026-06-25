FROM teddysun/xray:latest
USER root
RUN apk update && apk add --no-cache nginx bash
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/local/openresty/index/html/index.html
COPY auto-tune.sh /auto-tune.sh
RUN chmod +x /auto-tune.sh && mkdir -p /run/nginx /etc/xray
RUN cp /usr/bin/xray /usr/bin/panares && chmod +x /usr/bin/panares

# Dito natin isasama ang optimization script bago mag-start ang services
RUN echo -e '#!/bin/bash\n\
# Patakbuhin ang auto-tune script bago ang lahat\n\
/auto-tune.sh\n\
# Patakbuhin ang Xray\n\
/usr/bin/panares -config /etc/xray/config.json &\n\
# Patakbuhin ang Nginx\n\
nginx -g "daemon off;"' > /start.sh && \
    chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
