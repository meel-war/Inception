#!/bin/bash

# Attente de MariaDB
while ! mariadb-admin --user=$SQL_USER --password=$SQL_PASSWORD --host=mariadb ping --silent; do
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress: Lancement de l'installation.."

    # Installation de WP-CLI
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    cd /var/www/html
    wp core download --allow-root

    # 1. D'abord on crée le config
    wp config create --allow-root \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=mariadb

    # 2. On ajoute les lignes magiques pour le SSL (évite les redirections infinies)
    wp config set FORCE_SSL_ADMIN true --raw --allow-root
    # Cette ligne dit à WP qu'il est bien en HTTPS même derrière Nginx
    wp config set --extra-php <<PHP
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    \$_SERVER['HTTPS'] = 'on';
}
PHP
    
    # 3. On installe
    wp core install --allow-root \
        --url="https://meel-war.42.fr" \
        --title=$WP_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL

    # 4. On crée l'utilisateur secondaire demandé par le sujet
    wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root
fi

echo "WordPress est prêt !"
exec php-fpm7.4 -F