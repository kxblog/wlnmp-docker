FROM php:7.2-fpm-buster

# 声明构建参数
ARG TZ
# 将构建参数转为环境变量（可选）
ENV TZ=$TZ

# 更换源为阿里云镜像（buster 源）,清华源镜像（buster源替换）mirrors.ustc.edu.cn
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装时区支持并设置时区
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# 安装 PHP 扩展依赖

# 更新软件包列表, 安装常用依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends libzip-dev unzip zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libwebp-dev

# zip, pdo_mysql, pcntl, bcmath
RUN docker-php-ext-install zip pdo_mysql pcntl bcmath

# GD 扩展
RUN apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include && \
    docker-php-ext-install -j$(nproc) gd

# 更新 PECL channel, 安装 igbinary, Redis 扩展
RUN pecl channel-update pecl.php.net && \
    # 安装 igbinary 扩展
    pecl install -n igbinary && \
    docker-php-ext-enable igbinary && \
    # 手动编译安装 redis 扩展 (用 pecl install redis命令启用igbinary没成功)
    pecl download redis-5.3.2.tgz && \
    tar -zxvf redis-5.3.2.tgz && \
    cd redis-5.3.2 && \
    phpize && \
    ./configure --with-php-config=/usr/local/bin/php-config --enable-redis-igbinary && \
    make && make install && \
    docker-php-ext-enable redis

# memcached 扩展
RUN apt-get install -y autoconf automake make g++ && \
    pecl install memcache-4.0.5.2 && \
    docker-php-ext-enable memcache && \
    apt-get install -y libmemcached-dev zlib1g-dev && \
    pecl install memcached-3.1.3 && \
    docker-php-ext-enable memcached

# PHP扩展目录，自定义扩展文件放到这里面
# COPY xxx.so /usr/local/lib/php/extensions/
# 启用自定义扩展 - 对应上面的 xxx.so
# echo "zend_extension = /usr/local/lib/php/extensions/xxx.so" >> /usr/local/etc/php/conf.d/docker-php-ext-xxx.ini; \

# 清理 APT 缓存
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 新增入口脚本（在文件末尾添加）
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm"]