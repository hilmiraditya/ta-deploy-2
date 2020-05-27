FROM php:7.2-apache

WORKDIR /var/www/html

COPY / /var/www/html

RUN apt-get update && \
    apt-get install -y \
    git \
    zip \
    nano \
    curl

RUN docker-php-ext-install mbstring
RUN docker-php-ext-install pdo_mysql

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

RUN chown -R www-data:www-data /var/www

RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

COPY /apache /etc/apache2/sites-available

RUN composer install

RUN chown -R www-data:www-data /var/www/html
RUN a2enmod rewrite

EXPOSE 80