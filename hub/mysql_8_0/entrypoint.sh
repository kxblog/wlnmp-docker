#!/bin/sh

# 添加启动日志函数
log() {
    printf "[%s] %s\n" "$(date '+%Y-%m-%d %T')" "$@" >&2
}

log "🚀 启动容器入口脚本"

# 动态挂载配置文件（不覆盖容器内原有配置）
if [ -d "/wlnmp/mysql_8_0/conf.d" ]; then
    log "🗑  删除旧的符号链接"
    # 删除旧的符号链接（兼容 BusyBox 语法）
    find /etc/mysql/conf.d -type l | while read -r link; do
        if [ "$(readlink "$link")" != "${link#/etc/mysql/conf.d/}" ]; then
            rm -f "$link"
            log "  删除: $link"
        fi
    done
    
    log "🔗 创建新符号链接"
    # 使用符号链接方式加载配置文件
    find /wlnmp/mysql_8_0/conf.d -name '*.cnf' -exec ln -sfv {} /etc/mysql/conf.d/ \;

    log "🔒 设置配置文件权限"
    # 单独设置权限（如需要）
    find /etc/mysql/conf.d/ -name '*.cnf' -exec chmod 644 {} \;
    # find /wlnmp/mysql5.7/conf.d -name '*.cnf' -exec chmod 644 {} \;
fi


log "✅ 开始执行原始入口点"
# 先执行原始入口点
/usr/local/bin/docker-entrypoint.sh "$@"