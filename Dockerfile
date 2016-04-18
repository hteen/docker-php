FROM daocloud.io/php:7.0.2-fpm
# Install modules
RUN apt-get update && apt-get install -y \
        git \
        curl \
        libcurl4-gnutls-dev \
        freetds-dev \
        libbz2-dev \
        libc-client-dev \
        libenchant-dev \
        libfreetype6-dev \
        libgmp3-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libkrb5-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng12-dev \
        libpq-dev \
        libpspell-dev \
        libsasl2-dev \
        libsnmp-dev \
        libssl-dev \
        libtidy-dev \
        libxml2-dev \
        libxpm-dev \
        libxslt1-dev \
        zlib1g-dev \
    && docker-php-ext-install iconv zip curl bcmath bz2 calendar dba enchant exif ftp gd gettext intl mbstring mcrypt mysqli opcache pcntl pdo pdo_mysql pdo_pgsql pgsql pspell shmop snmp soap sockets sysvmsg sysvsem sysvshm tidy wddx xmlrpc xsl  \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN apt-get clean

RUN git clone -b php7 https://github.com/laruence/yaf.git /usr/src/php/ext/yaf/
RUN docker-php-ext-install yaf

RUN git clone -b php7 https://github.com/laruence/yar.git /usr/src/php/ext/yar/
RUN docker-php-ext-install yar

RUN git clone https://github.com/laruence/yaconf.git /usr/src/php/ext/yaconf/
RUN docker-php-ext-install yaconf

RUN git clone -b php7 https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis/
RUN docker-php-ext-install redis

ADD https://github.com/hteen/docker-php/blob/develop/php.ini /usr/local/etc/php/

CMD ["php-fpm"]