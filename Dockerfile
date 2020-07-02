FROM php:fpm-alpine
LABEL maintainer="Clarence <xjh.azzbcc@gmail.com>"

# 使用开发环境配置
RUN ln -fs "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# 安装nginx
RUN \
    apk add --no-cache nginx && \
    mkdir -p /run/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# 安装xdebug插件
RUN \
    apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    apk del --no-network .phpize-deps

# 配置xdebug
RUN \
    echo "xdebug.remote_enable=1" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_connect_back=1" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini

COPY docker-entrypoint.sh /
COPY default.conf /etc/nginx/conf.d/

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "php-fpm" ]
