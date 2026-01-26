FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

# Par defaut debian cherche a placer son socket dans /run/mysqld
# sauf que de base dans un debian vierge il n'y est pas 
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Par securite MariaDB est set a l'adresse 127.0.0.1, il n'ecoute que lui meme
# donc on le set a 0.0.0.0 pour accepter tout les connexions de tout les ips
RUN sed -i 's/bind-address = 127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

COPY db_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/db_setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/db_setup.sh"]