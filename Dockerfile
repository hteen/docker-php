FROM php:7.4.9-fpm

LABEL maintainer="i@hteen.cn"

ENV COMPOSER_MIRRORS https://mirrors.aliyun.com/composer/

# Install modules
RUN apt-get update && apt-get install -y \
        git \
        ssh \
        zip \
        unzip \
        libcurl4 \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        zlib1g-dev \
        libmcrypt-dev \
        libzip-dev \
        libgmp-dev \
        libmemcached-dev \
        libmemcached11 \
        libpcre3 \
        libpcre3-dev \
        --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && pecl install mcrypt-1.0.3 memcached-3.1.5 \
    && docker-php-ext-enable mcrypt memcached \
    && docker-php-ext-install -j$(nproc) iconv gmp \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp\
    && docker-php-ext-install -j$(nproc) gd

RUN git clone --depth=1 https://github.com/laruence/yaf.git /usr/src/php/ext/yaf/ \
    && git clone --depth=1 https://github.com/laruence/yar.git /usr/src/php/ext/yar/ \
    && git clone --depth=1 https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis/ \
    && git clone --depth=1 -b v4.5.2 https://github.com/swoole/swoole-src.git /usr/src/php/ext/swoole/ \
    && git clone --depth=1 https://github.com/msgpack/msgpack-php.git /usr/src/php/ext/msgpack/

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer ${COMPOSER_MIRRORS}

RUN docker-php-ext-install -j$(nproc) bcmath pdo_mysql mysqli opcache zip yaf redis swoole msgpack \
    && docker-php-ext-configure yar --enable-msgpack \
    && docker-php-ext-install -j$(nproc) yar pcntl

# 修改默认配置
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN set -eux; \
    { \
        echo 'post_max_size = 200M'; \
        echo 'upload_max_filesize = 200M'; \
        echo 'max_file_uploads = 200'; \
        echo 'memory_limit = 512M'; \
    } | tee -a $PHP_INI_DIR/php.ini; \
    { \
        echo 'pm.max_children = 512'; \
        echo 'pm.start_servers = 20'; \
        echo 'pm.min_spare_servers = 10'; \
        echo 'pm.max_spare_servers = 40'; \
        echo 'pm.max_requests = 1000'; \
    } | tee -a /usr/local/etc/php-fpm.d/www.conf