FROM php:8.0.6-fpm-alpine3.12

# composer 使用阿里云镜像
ENV COMPOSER_MIRRORS https://mirrors.aliyun.com/composer/
# 防止 composer 内存溢出
ENV COMPOSER_MEMORY_LIMIT -1
# 需要安装的扩展
ENV EXTENSIONS \
    swoole \
    redis \
    mcrypt \
    memcached \
    iconv \
    pcntl \
    gmp \
    gd \
    bcmath \
    pdo_mysql \
    mysqli \
    zip \
    opcache \
    @composer

# Easily install PHP extension in Docker containers
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN set -eux; \
    # 阿里云源
    # echo -e 'https://mirrors.aliyun.com/alpine/v3.12/main/' > /etc/apk/repositories; \
    # echo -e 'https://mirrors.aliyun.com/alpine/v3.12/community/' >> /etc/apk/repositories; \
    # apk update; \
    apk add --no-cache git; \
    chmod +x /usr/local/bin/install-php-extensions && sync && install-php-extensions ${EXTENSIONS};\
    # 全局设置 composer 源
    composer config -g repo.packagist composer ${COMPOSER_MIRRORS}; \
    # 修改默认配置
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
    { \
    echo 'post_max_size = 200M'; \
    echo 'upload_max_filesize = 200M'; \
    echo 'max_file_uploads = 200'; \
    echo 'memory_limit = 512M'; \
    # jit设置参考 https://www.laruence.com/2020/06/27/5963.html
    echo 'opcache.jit=1235'; \
    echo 'opcache.jit_buffer_size=64M'; \
    } | tee -a $PHP_INI_DIR/php.ini; \
    { \
    echo 'pm.max_children = 1024'; \
    echo 'pm.start_servers = 64'; \
    echo 'pm.min_spare_servers = 32'; \
    echo 'pm.max_spare_servers = 64'; \
    echo 'pm.max_requests = 1000'; \
    } | tee -a /usr/local/etc/php-fpm.d/www.conf

# fix work iconv library with alpine
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so