FROM php:fpm-alpine
LABEL maintainer="Clarence <xjh.azzbcc@gmail.com>"

# 配置 php-fpm
RUN \
    mkdir -p /run/php-fpm && \
    sed -i "s|^;listen.owner|listen.owner|" $PHP_INI_DIR/../php-fpm.d/www.conf && \
    sed -i "s|^;listen.group|listen.group|" $PHP_INI_DIR/../php-fpm.d/www.conf && \
    sed -i "s|^listen =.*9000|listen = /run/php-fpm/php-fpm.sock|" $PHP_INI_DIR/../php-fpm.d/*.conf && \
    ln -fs "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# 安装nginx
RUN \
    apk add --no-cache nginx && \
    mkdir -p /run/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# 配置nginx
RUN \
    sed -i "s|^user nginx;|user www-data;|" /etc/nginx/nginx.conf

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

# 安装mysqli
RUN docker-php-ext-install mysqli

# 安装zip
RUN \
    apk add --no-cache libzip-dev && \
    docker-php-ext-install zip

# 安装gd
RUN \
    apk add --no-cache libpng-dev libwebp-dev libjpeg-turbo-dev libxpm-dev freetype-dev && \
    docker-php-ext-configure gd --with-webp --with-jpeg --with-xpm --with-freetype && \
    docker-php-ext-install gd

ARG hostuid=1000
ARG hostgid=1000

# 创建用户
RUN \
    addgroup -g $hostgid runner && \
    adduser -s /sbin/nologin -u $hostuid -G runner -DH runner && \
    # 修改php-fpm执行用户
    sed -i "s|www-data|runner|" $PHP_INI_DIR/../php-fpm.d/www.conf && \
    # 修改nginx执行用户
    sed -i "s|^user www-data;|user runner;|" /etc/nginx/nginx.conf

COPY docker-entrypoint.sh /
COPY default.conf /etc/nginx/conf.d/

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "php-fpm" ]
