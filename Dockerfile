# --- build stage ---
FROM composer:2 AS build
WORKDIR /app
COPY composer.json composer.lock* ./
COPY app/ app/
COPY bootstrap/ bootstrap/
COPY routes/ routes/
COPY resources/ resources/
COPY artisan artisan
RUN composer install --no-dev --optimize-autoloader --no-scripts

# --- runtime stage ---
FROM php:8.5-apache
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /var/www/html
COPY --from=build /app ./
RUN chown -R www-data:www-data storage bootstrap/cache
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD php artisan --version || exit 1
EXPOSE 80
