# PHP Docker Image

基于官方的 PHP Docker 镜像，包含常用扩展和 Composer。

## 已安装的 PHP 扩展

主要扩展（通过 `install-php-extensions` 安装）：
- redis
- memcached
- pcntl
- gmp
- gd
- bcmath
- pdo_mysql
- mysqli
- zip
- opcache

## Composer

镜像已包含 Composer 2

## PHP 配置

- `post_max_size`: 200M
- `upload_max_filesize`: 200M
- `max_file_uploads`: 200
- `memory_limit`: 512M
- `opcache.enable`: 1
- `opcache.jit`: 1235
- `opcache.jit_buffer_size`: 64M

## PHP-FPM 配置

- `pm.max_children`: 256
- `pm.start_servers`: 16
- `pm.min_spare_servers`: 8
- `pm.max_spare_servers`: 16
- `pm.max_requests`: 1000
