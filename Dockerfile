FROM php:7.3.6-fpm

LABEL maintainer="i@hteen.cn"

# Install modules
RUN apt-get update && apt-get install -y \
        git \
        ssh \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libzip-dev \
        libpcre3 \
        libpcre3-dev \
        --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && pecl install mcrypt-1.0.2 \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN git clone https://github.com/laruence/yaf.git /usr/src/php/ext/yaf/
RUN git clone https://github.com/laruence/yar.git /usr/src/php/ext/yar/
RUN git clone https://github.com/laruence/yaconf.git /usr/src/php/ext/yaconf/
RUN git clone https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis/
RUN git clone https://github.com/swoole/swoole-src.git /usr/src/php/ext/swoole/
RUN git clone https://github.com/msgpack/msgpack-php.git /usr/src/php/ext/msgpack/

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN composer config -g repo.packagist composer https://packagist.laravel-china.org

COPY php.ini /usr/local/etc/php/php.ini

RUN docker-php-ext-install -j$(nproc) pdo_mysql mysqli opcache zip yaf yaconf redis swoole msgpack \
    && docker-php-ext-configure yar --enable-msgpack \
    && docker-php-ext-install -j$(nproc) yar pcntl
