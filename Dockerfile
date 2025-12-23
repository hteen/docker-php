FROM php:8.5-fpm-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1 \
    COMPOSER_CURL_DISABLE_HTTP2=1 \
    COMPOSER_MEMORY_LIMIT=-1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

ENV EXTENSIONS='redis mcrypt memcached pcntl gmp gd bcmath pdo_mysql mysqli zip opcache'
COPY --from=ghcr.io/mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions ${EXTENSIONS}

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
 && { \
      echo 'post_max_size = 200M'; \
      echo 'upload_max_filesize = 200M'; \
      echo 'max_file_uploads = 200'; \
      echo 'memory_limit = 512M'; \
      echo 'opcache.enable=1'; \
      echo 'opcache.jit=1235'; \
      echo 'opcache.jit_buffer_size=64M'; \
    } >> "$PHP_INI_DIR/php.ini" \
 && { \
      echo 'pm.max_children = 256'; \
      echo 'pm.start_servers = 16'; \
      echo 'pm.min_spare_servers = 8'; \
      echo 'pm.max_spare_servers = 16'; \
      echo 'pm.max_requests = 1000'; \
    } >> /usr/local/etc/php-fpm.d/www.conf