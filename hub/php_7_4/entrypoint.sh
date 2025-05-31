#!/bin/sh

# 动态挂载配置文件（不覆盖容器内原有配置）
if [ -d "/wlnmp/php_7_4/conf.d" ]; then
    # 删除旧的符号链接（兼容 BusyBox 语法）
    find /usr/local/etc/php/conf.d -type l | while read -r link; do
        if [ "$(readlink "$link")" != "${link#/usr/local/etc/php/conf.d/}" ]; then
            rm -f "$link"
        fi
    done
    
    # 使用符号链接方式加载配置文件
    find /wlnmp/php_7_4/conf.d -name '*.ini' -exec ln -sfv {} /usr/local/etc/php/conf.d/ \;

    # 单独设置权限（如需要）
    # find /wlnmp/php_7_4/conf.d -name '*.ini' -exec chmod 644 {} \;
fi

if [ -d "/wlnmp/php_7_4/php-fpm.d" ]; then
    # 删除旧的符号链接（兼容 BusyBox 语法）
    find /usr/local/etc/php-fpm.d -type l | while read -r link; do
        if [ "$(readlink "$link")" != "${link#/usr/local/etc/php-fpm.d/}" ]; then
            rm -f "$link"
        fi
    done
    
    # 使用符号链接方式加载配置文件
    find /wlnmp/php_7_4/php-fpm.d -name '*.conf' -exec ln -sfv {} /usr/local/etc/php-fpm.d/ \;

    # 单独设置权限（如需要）
    # find /wlnmp/php_7_4/php-fpm.d -name '*.conf' -exec chmod 644 {} \;
fi

# 执行原始入口点
/usr/local/bin/docker-php-entrypoint "$@"