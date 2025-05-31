#!/bin/bash
set -euo pipefail

# 设置端口并启动 - 按需修改
# export WLNMP_CP_HTTP_PORT=9000
export WLNMP_CP_HTTPS_PORT=9443
# export WLNMP_CP_AGENT_PORT=8000

# 获取脚本所在目录
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 构建基础命令
docker_cmd="docker compose --project-directory \"$SCRIPT_DIR\" -f \"$SCRIPT_DIR/hub/portainer/docker-compose.yml\" -f \"$SCRIPT_DIR/hub/portainer/docker-compose.linux.yml\""

# 处理 HTTPS 端口（9443）
if [ -n "${WLNMP_CP_HTTPS_PORT+x}" ] && [ -n "$WLNMP_CP_HTTPS_PORT" ]; then
    docker_cmd+=" -f \"$SCRIPT_DIR/hub/portainer/docker-compose.port-9443.yml\""
fi

# 处理 HTTP 端口（9000）
if [ -n "${WLNMP_CP_HTTP_PORT+x}" ] && [ -n "$WLNMP_CP_HTTP_PORT" ]; then
    docker_cmd+=" -f \"$SCRIPT_DIR/hub/portainer/docker-compose.port-9000.yml\""
fi

# 处理 AGENT 端口（8000）
if [ -n "${WLNMP_CP_AGENT_PORT+x}" ] && [ -n "$WLNMP_CP_AGENT_PORT" ]; then
    docker_cmd+=" -f \"$SCRIPT_DIR/hub/portainer/docker-compose.port-8000.yml\""
fi

# 添加用户参数并执行
docker_cmd+=" $*"
echo "执行命令：$docker_cmd"
eval "$docker_cmd"