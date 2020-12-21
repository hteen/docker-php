FROM php:7.4.13-fpm-alpine3.12

LABEL maintainer="i@hteen.cn"

# composer 使用阿里云镜像
ENV COMPOSER_MIRRORS https://mirrors.aliyun.com/composer/
# 防止 composer 内存溢出
ENV COMPOSER_MEMORY_LIMIT -1

RUN set -eux; \
    # 阿里云源
    # echo -e 'https://mirrors.aliyun.com/alpine/v3.12/main/' > /etc/apk/repositories; \
    # echo -e 'https://mirrors.aliyun.com/alpine/v3.12/community/' >> /etc/apk/repositories; \
    # apk update; \
    # 安装必备动态库
    apk add --no-cache \
        libpng \
        libjpeg-turbo \
        libwebp \
        gmp \
        freetype \
        libmcrypt \
        libmemcached \
        libzip; \
    # 安装编译时依赖, 后续删除
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
        libmemcached-dev \
        cyrus-sasl-dev \
        zlib-dev \
        git \
        gmp-dev \
        libpng-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        libzip-dev \
        libmcrypt-dev; \
    git clone --depth=1 https://github.com/php/pecl-encryption-mcrypt.git /usr/src/php/ext/mcrypt/; \
    git clone --depth=1 https://github.com/php-memcached-dev/php-memcached.git /usr/src/php/ext/memcached/; \
    git clone --depth=1 https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis/; \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-install -j$(nproc) redis mcrypt memcached iconv gmp gd bcmath pdo_mysql mysqli zip; \
    docker-php-ext-enable opcache; \
    # 安装 composer
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
    composer config -g repo.packagist composer ${COMPOSER_MIRRORS}; \
    rm composer-setup.php; \
    # 删除编译工具
    apk del --no-network .build-deps; \
    # 删除 php 源码
    rm -rf /usr/src/*;

# 修改默认配置
RUN set -eux; \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
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