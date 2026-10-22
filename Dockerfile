# PHP 8.1 已 EOL，Docker Hub 官方镜像未包含
# CVE-2026-109618 / CVE-2026-109619 修复。
# 这里基于 php-8.1.34，应用 PHP 安全组提供的最小源码回移植后重编：
# https://github.com/php/php-src/commit/1d7dec178a094e6e75b229ce22754045f8c6070a
FROM php:8.1.34-fpm-bookworm

COPY patches/8.1-CVE-2026-109618-109619.patch /usr/src/php-CVE-2026-109618-109619.patch

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        patch \
        libargon2-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        libreadline-dev \
        libsodium-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        zlib1g-dev \
    ; \
    docker-php-source extract; \
    patch -d /usr/src/php -p1 --forward --batch < /usr/src/php-CVE-2026-109618-109619.patch; \
    cd /usr/src/php; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    if [ ! -d /usr/include/curl ] && [ ! -e /usr/local/include/curl ]; then \
        ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
    fi; \
    export \
        CFLAGS="$PHP_CFLAGS" \
        CPPFLAGS="$PHP_CPPFLAGS" \
        LDFLAGS="$PHP_LDFLAGS" \
        PHP_BUILD_PROVIDER='https://github.com/docker-library/php' \
        PHP_UNAME='Linux - Docker' \
    ; \
    ./configure $(php-config --configure-options); \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    find /usr/local -type f -perm '/0111' -exec sh -euxc 'strip --strip-all "$@" || :' -- '{}' +; \
    make clean; \
    rm -f /usr/src/php/.docker-extracted /usr/src/php-CVE-2026-109618-109619.patch; \
    tar -C /usr/src -cJf /usr/src/php.tar.xz php; \
    cd /; \
    docker-php-source delete; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
        | sort -u \
        | xargs -rt dpkg-query --search \
        | awk 'sub(":$", "", $1) { print $1 }' \
        | sort -u \
        | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    php --version

ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1 \
    COMPOSER_CURL_DISABLE_HTTP2=1 \
    COMPOSER_MEMORY_LIMIT=-1

# owner/repo@tag 走 GitHub，避开 PECL REST latest。
# redis PECL tgz 的 package.xml 在包根，源码和 liblzf 在 redis-6.2.0/。
# 交给 URL 安装会在根目录找 liblzf/LICENSE，必然失败。
ADD https://pecl.php.net/get/redis-6.2.0.tgz /tmp/redis-6.2.0.tgz
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

ENV EXTENSIONS="php/pecl-encryption-mcrypt@1.0.7 php-memcached-dev/php-memcached@v3.3.0 Imagick/imagick@3.8.0 pcntl gmp gd bcmath pdo_mysql mysqli zip opcache @composer"

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
      echo 'post_max_size = 64M'; \
      echo 'upload_max_filesize = 64M'; \
      echo 'max_file_uploads = 20'; \
      echo 'memory_limit = 256M'; \
      echo 'opcache.enable=1'; \
      echo 'opcache.memory_consumption=64'; \
      echo 'opcache.interned_strings_buffer=8'; \
      echo 'opcache.jit=1235'; \
      echo 'opcache.jit_buffer_size=16M'; \
      echo 'session.upload_progress.enabled=0'; \
    } > "$PHP_INI_DIR/conf.d/99-custom.ini"; \
    { \
      echo 'pm = dynamic'; \
      echo 'pm.max_children = 8'; \
      echo 'pm.start_servers = 2'; \
      echo 'pm.min_spare_servers = 1'; \
      echo 'pm.max_spare_servers = 3'; \
      echo 'pm.max_requests = 500'; \
      echo 'php_admin_flag[session.upload_progress.enabled] = off'; \
    } >> /usr/local/etc/php-fpm.d/www.conf
