FROM php:fpm-alpine
LABEL maintainer="Clarence <xjh.azzbcc@gmail.com>"

# 使用开发环境配置
RUN ln -fs "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
