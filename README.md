# PHP Docker Image

基于官方的 PHP Docker 镜像，包含常用扩展和 Composer。

当前分支为 **PHP 8.2.35**。官方已包含 [CVE-2026-109618](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w) / [CVE-2026-109619](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp) 修复，无需再打源码补丁。

## 已安装的 PHP 扩展

通过 `install-php-extensions` 安装。mcrypt / memcached / imagick 从 GitHub tag 拉取；redis 用 PECL 6.2.0 完整包（先把 `package.xml` 放进源码目录，避开 PECL REST）：

- redis 6.2.0
- mcrypt 1.0.7（`php/pecl-encryption-mcrypt`）
- memcached 3.3.0（`php-memcached-dev/php-memcached`）
- imagick 3.8.0
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

## PHP / PHP-FPM 配置

镜像只保留构建兼容项（关闭 JIT、关闭 `session.upload_progress`），其余沿用官方默认。业务配置用 `-v` 挂进去即可，后加载的 `zz-*.ini` / `zz-*.conf` 会覆盖默认值：

```bash
docker run --rm \
  -v "$PWD/zz-app.ini:/usr/local/etc/php/conf.d/zz-app.ini:ro" \
  -v "$PWD/zz-app.conf:/usr/local/etc/php-fpm.d/zz-app.conf:ro" \
  ghcr.io/hteen/php:8.2
```
