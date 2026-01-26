FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=Alsace/L=Mulhouse/O=42/OU=42/CN=meel-war.42.fr/UID=meel-war"

COPY default.conf /etc/nginx/conf.d/default.conf

CMD nginx -g "daemon off;"