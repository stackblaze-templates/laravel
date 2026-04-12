FROM php:8.5-apache
RUN apt-get update && apt-get install -y libpq-dev zip unzip git && \
    docker-php-ext-install pdo pdo_pgsql && \
    a2enmod rewrite
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data storage bootstrap/cache
EXPOSE 80
