#!/bin/bash

echo "WordPress: Waiting MariaDB..."
while ! mariadb-admin --user=$SQL_USER  --password=$SQL_PASSWORD -P 3306 --host=mariadb ping --silent; do
    sleep 2
done

echo "MariaDB is up"
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress: Lancement de l'installation.."

    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    cd /var/www/html
    wp core download --allow-root

    wp config create --allow-root \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=mariadb
    
    wp config set WP_HOME 'https://meel-war.42.fr' --allow-root
    wp config set WP_SITEURL 'https://meel-war.42.fr' --allow-root

    wp core install --allow-root \
        --url=$WP_URL \
        --title=$WP_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL

    wp user create \
        $WP_USER    \
        $WP_USER_EMAIL  \
        --role=author   \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root
fi

exec php-fpm7.4 -F