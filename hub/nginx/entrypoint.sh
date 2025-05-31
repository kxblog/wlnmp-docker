#!/bin/sh

# 先执行原始入口点
/docker-entrypoint.sh

# 动态挂载配置文件（不覆盖容器内原有配置）
if [ -d "/wlnmp/nginx/conf.d" ]; then
    # 删除旧的符号链接（兼容 BusyBox 语法）
    find /etc/nginx/conf.d -type l | while read -r link; do
        if [ "$(readlink "$link")" != "${link#/etc/nginx/conf.d/}" ]; then
            rm -f "$link"
        fi
    done
    
    # 使用符号链接方式加载配置文件
    find /wlnmp/nginx/conf.d -name '*.conf' -exec ln -sfv {} /etc/nginx/conf.d/ \;

    # 单独设置权限（如需要）
    # find /wlnmp/nginx/conf.d -name '*.conf' -exec chmod 644 {} \;
fi

# 执行原始入口命令
exec "$@"