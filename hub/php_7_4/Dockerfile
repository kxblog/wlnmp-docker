FROM php:7.4-fpm-buster

# 声明构建参数
ARG TZ
# 将构建参数转为环境变量（可选）
ENV TZ=$TZ
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# PHP扩展目录，自定义扩展文件放到这里面
# COPY xxx.so /usr/local/lib/php/extensions/

# 备份原始 sources.list 文件
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    # 替换为阿里云镜像源
    sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com\/debian-security/g' /etc/apt/sources.list && \
    # 更新软件包列表
    apt-get update && \
    # 安装常用依赖
    apt-get install -y --no-install-recommends \
        libzip-dev \
        unzip \
        zlib1g-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev && \
    # 安装并启用 zip 扩展
    docker-php-ext-install zip pdo_mysql pcntl bcmath && \
    # 安装并启用 gd 扩展
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) gd

# 安装 Redis 扩展
RUN apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        make \
        g++ && \
    # 更新 PECL channel
    pecl channel-update pecl.php.net && \
    # 安装 igbinary 扩展
    pecl install -n igbinary && \
    docker-php-ext-enable igbinary && \
    # 手动编译安装 redis 扩展
    pecl download redis && \
    tar -zxvf redis-6.2.0.tgz && \
    cd redis-6.2.0 && \
    phpize && \
    ./configure --with-php-config=/usr/local/bin/php-config --enable-redis-igbinary && \
    make && make install && \
    docker-php-ext-enable redis

# 清理 APT 缓存
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 新增入口脚本（在文件末尾添加）
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]