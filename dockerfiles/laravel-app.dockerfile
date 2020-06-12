FROM php:7.2-fpm

RUN apt-get update && apt-get install -y \
        libzip-dev \
        libmagickcore-dev \
        libmagickwand-dev \
        libmagic-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libmemcached-dev \
        zlib1g-dev \
        git \
        sudo \
        libmcrypt-dev \
        unzip && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install pdo_mysql && \
    pecl install zip-1.15.2 && \
    pecl install xdebug-2.6.0beta1 && \
    pecl install memcached-3.0.4 && \
    pecl install mcrypt-1.0.1 && \
    pecl install imagick-3.4.3 && \
    docker-php-ext-enable xdebug memcached mcrypt imagick zip

RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

WORKDIR /var/www
