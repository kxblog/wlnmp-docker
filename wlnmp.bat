@echo off
REM 该文件必须以 UTF-8 编码保存
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 设置端口并启动 - 按需修改
@REM set WLNMP_CP_HTTP_PORT=9000
set WLNMP_CP_HTTPS_PORT=9443
@REM set WLNMP_CP_AGENT_PORT=8000

REM 设置基础命令
set "DOCKER_COMMAND=docker compose --project-directory %~dp0 -f %~dp0\hub\portainer\docker-compose.yml -f %~dp0\hub\portainer\docker-compose.win.yml"

REM 处理 HTTPS 端口（9443）
if defined WLNMP_CP_HTTPS_PORT (
    if not "!WLNMP_CP_HTTPS_PORT!"=="" (
        set "DOCKER_COMMAND=!DOCKER_COMMAND! -f %~dp0\hub\portainer\docker-compose.port-9443.yml"
    )
)

REM 处理 HTTP 端口（9000）
if defined WLNMP_CP_HTTP_PORT (
    if not "!WLNMP_CP_HTTP_PORT!"=="" (
        set "DOCKER_COMMAND=!DOCKER_COMMAND! -f %~dp0\hub\portainer\docker-compose.port-9000.yml"
    )
)

REM 处理 AGENT 端口（8000）
if defined WLNMP_CP_AGENT_PORT (
    if not "!WLNMP_CP_AGENT_PORT!"=="" (
        set "DOCKER_COMMAND=!DOCKER_COMMAND! -f %~dp0\hub\portainer\docker-compose.port-8000.yml"
    )
)

REM 添加用户输入的参数并执行
set "DOCKER_COMMAND=!DOCKER_COMMAND! %*"
echo 执行命令：!DOCKER_COMMAND!
!DOCKER_COMMAND!

endlocal
