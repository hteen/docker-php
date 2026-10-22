# PHP Docker Image

基于官方的 PHP Docker 镜像，包含常用扩展和 Composer。

当前分支为 **PHP 8.1.34**，并已打上 PHP 安全组提供的最小源码回移植，修复：

- [CVE-2026-109618](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w)（OOM 中断导致的请求状态损坏，可 RCE）
- [CVE-2026-109619](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp)（跨请求残留全局状态，可 RCE）

补丁来源：[`php-src@1d7dec178a`](https://github.com/php/php-src/commit/1d7dec178a094e6e75b229ce22754045f8c6070a)（分支 `PHP-8.1-CVE-2026-109618-109619`）。

> PHP 8.1 已 EOL，官方不再发正式版本。`php -v` 仍显示 `8.1.34`。这只回移植了上述两个漏洞，其它 8.1.34 之后的问题不会修复。能升级到 8.2.35 / 8.3.36 / 8.4.27 / 8.5.12 时请尽快升级。

回移植会改变部分行为：

- 内存耗尽时 worker 立即 `_exit(1)`，不再走原来的 `longjmp` 清理路径；FPM 会拉起新 worker
- `session.upload_progress` 被禁用

## 已安装的 PHP 扩展

通过 `install-php-extensions` 安装。mcrypt / memcached / imagick 从 GitHub tag 拉取；redis 用 PECL 6.2.0 完整包（先把 `package.xml` 放进源码目录，避免找不到 `liblzf`）：

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

由 `install-php-extensions @composer` 安装

## PHP 配置

面向 2 核 4GB、同机跑 MySQL / Redis / Caddy 的机器：

- `post_max_size`: 64M
- `upload_max_filesize`: 64M
- `max_file_uploads`: 20
- `memory_limit`: 256M
- `opcache.enable`: 1
- `opcache.memory_consumption`: 64
- `opcache.interned_strings_buffer`: 8
- `opcache.jit`: 1235
- `opcache.jit_buffer_size`: 16M
- `session.upload_progress.enabled`: 0

## PHP-FPM 配置

- `pm`: dynamic
- `pm.max_children`: 8
- `pm.start_servers`: 2
- `pm.min_spare_servers`: 1
- `pm.max_spare_servers`: 3
- `pm.max_requests`: 500
