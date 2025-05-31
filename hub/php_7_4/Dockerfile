FROM php:7.4-fpm-alpine

# PHP扩展目录，自定义扩展文件放到这里面
# COPY xxx.so /usr/local/lib/php/extensions/

# 备份原始 repositories 文件
RUN cp /etc/apk/repositories /etc/apk/repositories.bak; \
    # sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories; \
    # 修改 repositories 文件为阿里云镜像源
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    # 更新软件包列表
    apk update; \
    # 安装 libzip-dev unzip 扩展，安装 pdo_mysql 扩展
    apk add --no-cache \
        libzip-dev unzip \
        && docker-php-ext-install zip pdo_mysql; \
    # 安装 GD 扩展
    apk add --no-cache \
        freetype-dev libjpeg-turbo-dev libpng-dev \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/user/include/ \
        && docker-php-ext-install -j$(nproc) gd; \
    # 安装 Redis 扩展
    apk add --no-cache autoconf automake make g++ \
        && pecl channel-update pecl.php.net \
        && pecl install -n igbinary \
        && docker-php-ext-enable igbinary \
        && pecl install -n --configureoptions 'enable-redis-igbinary="yes"' redis-6.2.0 \
        && docker-php-ext-enable redis;
    # 启用自定义扩展 - 对应上面的 COPY xxx.so /usr/local/lib/php/extensions/
    # echo "zend_extension = /usr/local/lib/php/extensions/xxx.so" >> /usr/local/etc/php/conf.d/docker-php-ext-ioncube.ini; \

# 新增入口脚本（在文件末尾添加）
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm"]