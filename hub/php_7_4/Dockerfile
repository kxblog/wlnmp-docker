FROM php:7.4-fpm-buster

# 声明构建参数
ARG TZ
# 将构建参数转为环境变量（可选）
ENV TZ=$TZ

# 备份原始 sources.list 文件，更新源为阿里云镜像（buster源替换）,清华源镜像（buster源替换）mirrors.ustc.edu.cn
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    # 替换为阿里云镜像源
    sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装tzdata包并设置时区
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

# 安装并启用 gd 扩展
RUN apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) gd

# 更新 PECL channel, 安装 igbinary, Redis 扩展
RUN pecl channel-update pecl.php.net && \
    # 安装 igbinary 扩展
    pecl install -n igbinary && \
    docker-php-ext-enable igbinary && \
    # 手动编译安装 redis 扩展 (php7.4以上版本,用 pecl install redis命令启用igbinary没成功)
    pecl download redis && \
    tar -zxvf redis-6.2.0.tgz && \
    cd redis-6.2.0 && \
    phpize && \
    ./configure --with-php-config=/usr/local/bin/php-config --enable-redis-igbinary && \
    make && make install && \
    docker-php-ext-enable redis

# 安装 memcached 扩展
RUN apt-get install -y autoconf automake make g++ libmemcached-dev zlib1g-dev \
        && pecl install -n memcache \
        && docker-php-ext-enable memcache \
        && pecl install -n memcached \
        && docker-php-ext-enable memcached

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