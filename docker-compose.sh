#!/bin/bash

# 设置 WLNMP_ROOT_DIR 为 docker-compose.sh 脚本所在目录
export WLNMP_ROOT_DIR="$(dirname "$(realpath "$0")")"

# 新增.env文件检查逻辑
if [ ! -f ".env" ]; then
    echo "错误：当前目录缺少 .env 文件" >&2
    exit 1
fi

# 从.env读取配置并检查有效性
export WLNMP_SERVER_NAME=$(
    grep -E '^[[:space:]]*WLNMP_SERVER_NAME[[:space:]]*=' .env |
    grep -v '^#' |
    cut -d '=' -f 2- |
    sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
)
if [ -z "$WLNMP_SERVER_NAME" ]; then
    echo "错误：.env 文件中缺少有效的 WLNMP_SERVER_NAME 配置" >&2
    exit 1
fi

# 拼接 WLNMP_SERVER_DIR 的值
export WLNMP_SERVER_DIR="${WLNMP_ROOT_DIR}/${WLNMP_SERVER_NAME}"

# 记录用户执行 docker-compose.sh 时的原始目录
ORIGINAL_DIR="$(pwd -P)"  # 使用物理路径避免符号链接干扰

# 判断 WLNMP_SERVER_DIR 目录下的 WLNMP_SERVER_NAME.sh 文件是否存在
if [ ! -f "${WLNMP_SERVER_DIR}/${WLNMP_SERVER_NAME}.sh" ]; then
    echo "错误：${WLNMP_SERVER_DIR}/${WLNMP_SERVER_NAME}.sh 文件不存在。"
    exit 1
fi

# 切换到 WLNMP_ROOT_DIR 目录（添加错误详情）
cd "${WLNMP_ROOT_DIR}" || { echo "无法切换到目录: ${WLNMP_ROOT_DIR}"; exit 1; }

# 重组剩余参数以处理带空格参数（新增参数处理逻辑）
declare -a args=("$@")

# 执行调试信息输出（新增调试日志）
echo "[DEBUG] 即将执行脚本: ${WLNMP_SERVER_DIR}/${WLNMP_SERVER_NAME}.sh" "${args[@]}"

# 执行 docker-compose.sh 脚本并传递剩余参数，捕获退出状态
EXIT_CODE=0
if ! bash "${WLNMP_SERVER_DIR}/${WLNMP_SERVER_NAME}.sh" "${args[@]}"; then
    echo "错误：执行 ${WLNMP_SERVER_DIR}/${WLNMP_SERVER_NAME}.sh 脚本失败，错误码 $?" >&2
    EXIT_CODE=1
fi

# 切换回原来用户执行 docker-compose.sh 时的目录
cd "${ORIGINAL_DIR}" || exit

# 清除临时环境变量
unset ORIGINAL_DIR WLNMP_ROOT_DIR WLNMP_SERVER_NAME WLNMP_SERVER_DIR

exit $EXIT_CODE