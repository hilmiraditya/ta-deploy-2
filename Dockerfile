# FROM php:7.2-apache

# WORKDIR /var/www/html

# COPY / /var/www/html

# RUN apt-get update && \
#     apt-get install -y \
#     git \
#     zip \
#     nano \
#     curl

# RUN docker-php-ext-install mbstring
# RUN docker-php-ext-install pdo_mysql

# RUN curl -sS https://getcomposer.org/installer | php
# RUN mv composer.phar /usr/local/bin/composer
# RUN chmod +x /usr/local/bin/composer

# RUN chown -R www-data:www-data /var/www

# RUN groupadd -g 1000 www
# RUN useradd -u 1000 -ms /bin/bash -g www www

# COPY /apache /etc/apache2/sites-available

# RUN composer install

# RUN chown -R www-data:www-data /var/www/html
# RUN a2enmod rewrite

# EXPOSE 80



# FROM bkuhl/fpm-nginx:7.4.2

# WORKDIR /var/www/html

# COPY / /var/www/html
# # Copy the application files to the container
# ADD --chown=www-data:www-data  . /var/www/html

# USER www-data

#     # production-ready dependencies
# RUN composer install  --no-interaction --optimize-autoloader --no-dev --prefer-dist \
#     # keep the container light weight
#     && rm -rf /home/www-data/.composer/cache
# USER root



FROM php:7.4-fpm

RUN apt-get update -y \
    && apt-get install -y nginx \
    && apt-get install -y \
    git \
    zip \
    nano \
    curl

# PHP_CPPFLAGS are used by the docker-php-ext-* scripts
ENV PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11"

RUN docker-php-ext-install pdo_mysql \
    && docker-php-ext-install opcache \
    && apt-get install libicu-dev -y \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && apt-get remove libicu-dev icu-devtools -y

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/php-opocache-cfg.ini

COPY nginx-site.conf /etc/nginx/sites-enabled/default
COPY entrypoint.sh /etc/entrypoint.sh

COPY --chown=www-data:www-data . /var/www/mysite

WORKDIR /var/www/mysite

RUN composer install

EXPOSE 80 443

ENTRYPOINT ["/etc/entrypoint.sh"]