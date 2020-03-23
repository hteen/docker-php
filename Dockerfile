FROM php:7.4.4-fpm

LABEL maintainer="i@hteen.cn"

ENV COMPOSER_MIRRORS https://mirrors.aliyun.com/composer/

# Install modules
RUN apt-get update && apt-get install -y \
        git \
        ssh \
        zip \
        unzip \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libzip-dev \
        libgmp-dev \
        libmemcached-dev \
        libmemcached11 \
        libpcre3 \
        libpcre3-dev \
        --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && pecl install mcrypt-1.0.3 memcached \
    && docker-php-ext-enable mcrypt memcached \
    && docker-php-ext-install -j$(nproc) iconv gmp \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN git clone --depth=1 https://github.com/laruence/yaf.git /usr/src/php/ext/yaf/ \
    && git clone --depth=1 https://github.com/laruence/yar.git /usr/src/php/ext/yar/ \
    && git clone --depth=1 https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis/ \
    && git clone --depth=1 -b v4.4.16 https://github.com/swoole/swoole-src.git /usr/src/php/ext/swoole/ \
    && git clone --depth=1 https://github.com/msgpack/msgpack-php.git /usr/src/php/ext/msgpack/

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer ${COMPOSER_MIRRORS}

RUN docker-php-ext-install -j$(nproc) bcmath pdo_mysql mysqli opcache zip yaf redis swoole msgpack \
    && docker-php-ext-configure yar --enable-msgpack \
    && docker-php-ext-install -j$(nproc) yar pcntl
