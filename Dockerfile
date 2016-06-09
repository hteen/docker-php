FROM php:7.0.7-fpm

MAINTAINER hteen <i@hteen.cn>

# Install modules
RUN apt-get update && apt-get install -y \
        git \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN apt-get clean

RUN git clone -b php7 https://github.com/laruence/yaf.git /usr/src/php/ext/yaf/
RUN docker-php-ext-install yaf

RUN git clone -b php7 https://github.com/laruence/yar.git /usr/src/php/ext/yar/
RUN docker-php-ext-install yar

RUN git clone https://github.com/laruence/yaconf.git /usr/src/php/ext/yaconf/
RUN docker-php-ext-install yaconf

RUN git clone -b php7 https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis/
RUN docker-php-ext-install redis

CMD ["php-fpm"]
