FROM php:8.2.35-fpm-bookworm

# 防止 composer 内存溢出
ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1 \
    COMPOSER_CURL_DISABLE_HTTP2=1 \
    COMPOSER_MEMORY_LIMIT=-1

ENV EXTENSIONS="php/pecl-encryption-mcrypt@1.0.7 php-memcached-dev/php-memcached@v3.3.0 Imagick/imagick@3.8.0 pcntl gmp gd bcmath pdo_mysql mysqli zip opcache"

ADD https://pecl.php.net/get/redis-6.2.0.tgz /tmp/redis-6.2.0.tgz
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git; \
    rm -rf /var/lib/apt/lists/*; \
    tar -xzf /tmp/redis-6.2.0.tgz -C /tmp; \
    cp /tmp/package.xml /tmp/redis-6.2.0/package.xml; \
    install-php-extensions /tmp/redis-6.2.0 ${EXTENSIONS}; \
    rm -rf /tmp/redis-6.2.0 /tmp/package.xml /tmp/redis-6.2.0.tgz; \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
    { \
      echo 'post_max_size = 200M'; \
      echo 'upload_max_filesize = 200M'; \
      echo 'max_file_uploads = 200'; \
      echo 'memory_limit = 384M'; \
      echo 'opcache.enable = 1'; \
      echo 'opcache.jit = 0'; \
      echo 'opcache.jit_buffer_size = 0'; \
      echo 'session.upload_progress.enabled = 0'; \
    } > "$PHP_INI_DIR/conf.d/99-custom.ini"; \
    { \
      echo 'pm.max_children = 6'; \
      echo 'pm.start_servers = 2'; \
      echo 'pm.min_spare_servers = 1'; \
      echo 'pm.max_spare_servers = 3'; \
      echo 'pm.max_requests = 300'; \
      echo 'php_admin_flag[session.upload_progress.enabled] = off'; \
    } >> /usr/local/etc/php-fpm.d/www.conf
