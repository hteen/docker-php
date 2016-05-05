# Docker php7
docker php-fpm images

# Add php extension
iconv zip curl bcmath bz2 calendar dba enchant exif ftp gettext intl mbstring mcrypt mysqli opcache pcntl pdo pdo_mysql pdo_pgsql pgsql pspell shmop snmp soap sockets sysvmsg sysvsem sysvshm tidy wddx xmlrpc xsl gd yaf yar yaconf redis

# Usage

Add php.ini
```yaml
volumes:
  - php.ini::/usr/local/etc/php/php.ini
```
