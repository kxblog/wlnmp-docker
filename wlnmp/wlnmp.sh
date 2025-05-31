#!/bin/bash
set -euo pipefail

# 主执行流程
main() {
    # 1. 初始化环境变量
    export WLNMP_ROOT_DIR="${WLNMP_ROOT_DIR:-$(realpath "$(dirname "$0")/..")}"
    export WLNMP_SERVER_NAME="${WLNMP_SERVER_NAME:-$(basename "$(realpath "$(dirname "$0")")")}"
    export WLNMP_SERVER_DIR="${WLNMP_SERVER_DIR:-$(realpath "$(dirname "$0")")}"
    WLNMP_ROOT_DIR="${WLNMP_ROOT_DIR//\\//}"

    # 2. 检查主环境文件
    local server_env_file="${WLNMP_SERVER_DIR}/.${WLNMP_SERVER_NAME}.env"
    [ -f "$server_env_file" ] || { echo "错误：环境文件 $server_env_file 不存在" >&2; exit 1; }

    # 提取并验证网站目录
    export LINUX_WLNMP_WWW_DIR=$(grep -E '^[[:space:]]*LINUX_WLNMP_WWW_DIR=' "$server_env_file" | cut -d'=' -f2- | tr -d '[:space:]')
    LINUX_WLNMP_WWW_DIR=$(eval echo "$LINUX_WLNMP_WWW_DIR")  # 新增行：解析~符号
    [ -n "$LINUX_WLNMP_WWW_DIR" ] || { echo "错误：缺少 LINUX_WLNMP_WWW_DIR 配置" >&2; exit 1; }
    [ -d "$LINUX_WLNMP_WWW_DIR" ] || { echo "错误：网站目录不存在 $LINUX_WLNMP_WWW_DIR" >&2; exit 1; }
    export WLNMP_WWW_DIR="${LINUX_WLNMP_WWW_DIR}"  # 新增行：设置全局变量

    # 3. 准备运行时目录
    export WLNMP_RUNTIME_DIR="${WLNMP_ROOT_DIR}/runtime"
    mkdir -p "$WLNMP_RUNTIME_DIR"
    mkdir -p "${WLNMP_RUNTIME_DIR}/${WLNMP_SERVER_NAME}/nginx"
    mkdir -p "${WLNMP_RUNTIME_DIR}/${WLNMP_SERVER_NAME}/mysql_5_7"
    mkdir -p "${WLNMP_RUNTIME_DIR}/${WLNMP_SERVER_NAME}/mysql_8_0"

    # 4. 构建 Docker 命令
    local service_base="${WLNMP_ROOT_DIR}/hub/base"
    local service_nginx="${WLNMP_ROOT_DIR}/hub/nginx"
    local service_mysql_5_7="${WLNMP_ROOT_DIR}/hub/mysql_5_7"
    local service_mysql_8_0="${WLNMP_ROOT_DIR}/hub/mysql_8_0"
    local service_php_7_2="${WLNMP_ROOT_DIR}/hub/php_7_2"
    local service_php_7_3="${WLNMP_ROOT_DIR}/hub/php_7_3"
    local service_php_7_4="${WLNMP_ROOT_DIR}/hub/php_7_4"
    local service_php_8_2="${WLNMP_ROOT_DIR}/hub/php_8_2"
    local docker_cmd=(
        docker compose 
        --project-directory "$WLNMP_ROOT_DIR"
        -f "${service_base}/docker-compose.yml"
        -f "${service_nginx}/docker-compose.yml"
        -f "${service_mysql_5_7}/docker-compose.yml"
        -f "${service_mysql_8_0}/docker-compose.yml"
        -f "${service_php_7_2}/docker-compose.yml"
        -f "${service_php_7_3}/docker-compose.yml"
        -f "${service_php_7_4}/docker-compose.yml"
        -f "${service_php_8_2}/docker-compose.yml"
    )

    # 5. 添加环境文件
    local base_env="${WLNMP_SERVER_DIR}/base/.base.env"
    local nginx_env="${WLNMP_SERVER_DIR}/nginx/.nginx.env"
    local mysql_5_7_env="${WLNMP_SERVER_DIR}/mysql_5_7/.mysql_5_7.env"
    local mysql_8_0_env="${WLNMP_SERVER_DIR}/mysql_8_0/.mysql_8_0.env"
    [ -f "$base_env" ] && docker_cmd+=(--env-file "$base_env")
    [ -f "$nginx_env" ] && docker_cmd+=(--env-file "$nginx_env")
    docker_cmd+=(--env-file "${service_mysql_5_7}/.env")
    [ -f "$mysql_5_7_env" ] && docker_cmd+=(--env-file "$mysql_5_7_env")
    docker_cmd+=(--env-file "${service_mysql_8_0}/.env")
    [ -f "$mysql_8_0_env" ] && docker_cmd+=(--env-file "$mysql_8_0_env")

    # 6.1 端口配置检测
    local http_port="" https_port=""
    if [ -f "$nginx_env" ]; then
        http_port=$(grep -E '^[[:space:]]*NGINX_HTTP_PORT=' "$nginx_env" | cut -d'=' -f2- | tr -d '[:space:]')
        https_port=$(grep -E '^[[:space:]]*NGINX_HTTPS_PORT=' "$nginx_env" | cut -d'=' -f2- | tr -d '[:space:]')
    fi

    # 添加端口配置文件
    if [ -n "$http_port" ] && [ -n "$https_port" ]; then
        docker_cmd+=(-f "${service_nginx}/docker-compose.ports.yml")
    elif [ -n "$http_port" ]; then
        docker_cmd+=(-f "${service_nginx}/docker-compose.port-80.yml")
    elif [ -n "$https_port" ]; then
        docker_cmd+=(-f "${service_nginx}/docker-compose.port-443.yml")
    fi

    # 6.2 端口配置检测
    local mysql_5_7_host_port=""
    if [ -f "$mysql_5_7_env" ]; then
        # 安全获取配置值
        local tmp_line=$(grep -E '^[[:space:]]*MYSQL_5_7_HOST_PORT=' "$mysql_5_7_env" 2>/dev/null)
        if [ -n "$tmp_line" ]; then
            mysql_5_7_host_port=$(echo "$tmp_line" | cut -d'=' -f2- | tr -d '[:space:]')
        fi
    fi
    # 添加端口配置文件
    if [ -n "$mysql_5_7_host_port" ]; then
        docker_cmd+=(-f "${service_mysql_5_7}/docker-compose.port-3306.yml")
    fi

    local mysql_8_0_host_port=""
    if [ -f "$mysql_8_0_env" ]; then
        # 安全获取配置值
        local tmp_line=$(grep -E '^[[:space:]]*MYSQL_8_0_HOST_PORT=' "$mysql_8_0_env" 2>/dev/null)
        if [ -n "$tmp_line" ]; then
            mysql_8_0_host_port=$(echo "$tmp_line" | cut -d'=' -f2- | tr -d '[:space:]')
        fi
    fi
    # 添加端口配置文件
    if [ -n "$mysql_8_0_host_port" ]; then
        docker_cmd+=(-f "${service_mysql_8_0}/docker-compose.port-3306.yml")
    fi

    # 7. 执行最终命令
    docker_cmd+=("$@")
    echo "执行命令：${docker_cmd[*]}"
    "${docker_cmd[@]}"
}

main "$@"