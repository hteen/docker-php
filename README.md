# PHP Docker Image

基于官方的 PHP Docker 镜像，包含常用扩展和 Composer。

当前分支为 **PHP 8.5.12**。官方已包含 [CVE-2026-109618](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w) / [CVE-2026-109619](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp) 修复，无需再打源码补丁。

## 已安装的 PHP 扩展

通过 `install-php-extensions` 安装。mcrypt / memcached / imagick 从 GitHub tag 拉取；redis 用 PECL 6.3.0 完整包（PHP 8.5 需要，先把 `package.xml` 放进源码目录，避开 PECL REST）：

- redis 6.3.0
- mcrypt 1.0.9（`php/pecl-encryption-mcrypt`，支持 PHP 8.4 / 8.5）
- memcached 3.4.0（`php-memcached-dev/php-memcached`，PHP 8.5 需要）
- imagick 3.8.1（PHP 8.5 需要）
- pcntl
- gmp
- gd
- bcmath
- pdo_mysql
- mysqli
- zip
- opcache

## Composer

由官方 `composer:2` 镜像复制（避开本机访问 `composer.github.io` 不稳定）

## PHP 配置

- `post_max_size`: 200M
- `upload_max_filesize`: 200M
- `max_file_uploads`: 200
- `memory_limit`: 384M
- `opcache.enable`: 1
- `opcache.jit`: 0
- `opcache.jit_buffer_size`: 0
- `session.upload_progress.enabled`: 0

## PHP-FPM 配置

- `pm.max_children`: 6
- `pm.start_servers`: 2
- `pm.min_spare_servers`: 1
- `pm.max_spare_servers`: 3
- `pm.max_requests`: 300
