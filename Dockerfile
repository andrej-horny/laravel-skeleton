# Use PHP 8.2 with Apache
FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Copy Apache configuration
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install required system packages & PHP extensions
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        libzip-dev \
        libicu-dev \
        zip \
        unzip \
        curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip intl \
    && echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Set Composer environment variables
ENV COMPOSER_HOME="/var/www/.composer"
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . .

# Grant www-data sudo rights before switching user
RUN usermod -aG sudo www-data && chown -R www-data:www-data /var/www

# Switch to non-root user
USER www-data

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
