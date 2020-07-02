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

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "php-fpm" ]
