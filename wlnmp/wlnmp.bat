@echo off
REM 注意：该文件必须以 UTF-8 编码保存
rem 设置编码为 UTF-8
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 1. 判断环境变量是否存在，不存在则初始化
if "%WLNMP_ROOT_DIR%"=="" (
    set "WLNMP_ROOT_DIR=%~dp0..\"
    set "WLNMP_ROOT_DIR=!WLNMP_ROOT_DIR:~0,-1!"
)
if "%WLNMP_SERVER_NAME%"=="" (
    for %%I in ("%~dp0.") do set "WLNMP_SERVER_NAME=%%~nxI"
)
if "%WLNMP_SERVER_DIR%"=="" (
    set "WLNMP_SERVER_DIR=%~dp0"
    set "WLNMP_SERVER_DIR=!WLNMP_SERVER_DIR:~0,-1!"
)

REM 2. 判断 .{WLNMP_SERVER_NAME}.env 文件是否存在
set "SERVER_ENV_FILE=%WLNMP_SERVER_DIR%\.%WLNMP_SERVER_NAME%.env"
if not exist "%SERVER_ENV_FILE%" (
    echo 错误：%SERVER_ENV_FILE% 文件不存在。
    exit /b 1
)

REM 3. 判断 SERVER_ENV_FILE 中是否存在 WLNMP_WWW_DIR 值
set "WIN_WLNMP_WWW_DIR="
REM 添加 eol=# 选项，跳过以 # 开头的注释行
for /f "usebackq delims== tokens=1,2 eol=#" %%a in ("%SERVER_ENV_FILE%") do (
    if "%%a"=="WIN_WLNMP_WWW_DIR" (
        set "WIN_WLNMP_WWW_DIR=%%b"
    )
)
if not defined WIN_WLNMP_WWW_DIR (
    echo 错误：%SERVER_ENV_FILE% 中不存在 WIN_WLNMP_WWW_DIR 值。
    exit /b 1
)
if not exist "%WIN_WLNMP_WWW_DIR%" (
    echo 错误：WIN_WLNMP_WWW_DIR 值 %WIN_WLNMP_WWW_DIR% 不是一个有效的目录。
    exit /b 1
)
set "WIN_WLNMP_WWW_DIR=%WIN_WLNMP_WWW_DIR%"
set "WLNMP_WWW_DIR=%WIN_WLNMP_WWW_DIR%"

REM 4. 设置 WLNMP_RUNTIME_DIR 环境变量，不存在则创建目录
set "WLNMP_RUNTIME_DIR=%WLNMP_ROOT_DIR%\runtime"
if not exist "%WLNMP_RUNTIME_DIR%" (
    mkdir "%WLNMP_RUNTIME_DIR%"
)
if not exist "%WLNMP_RUNTIME_DIR%\%WLNMP_SERVER_NAME%\nginx" (
    mkdir "%WLNMP_RUNTIME_DIR%\%WLNMP_SERVER_NAME%\nginx"
)
if not exist "%WLNMP_RUNTIME_DIR%\%WLNMP_SERVER_NAME%\mysql_5_7" (
    mkdir "%WLNMP_RUNTIME_DIR%\%WLNMP_SERVER_NAME%\mysql_5_7"
)
if not exist "%WLNMP_RUNTIME_DIR%\%WLNMP_SERVER_NAME%\mysql_8_0" (
    mkdir "%WLNMP_RUNTIME_DIR%\%WLNMP_SERVER_NAME%\mysql_8_0"
)

REM 5. 设置各个 service 的 yml 文件路径环境变量
set "WLNMP_SERVICE_BASE=%WLNMP_ROOT_DIR%\hub\base"
set "WLNMP_SERVICE_NGINX=%WLNMP_ROOT_DIR%\hub\nginx"
set "WLNMP_SERVICE_MYSQL_5_7=%WLNMP_ROOT_DIR%\hub\mysql_5_7"
set "WLNMP_SERVICE_MYSQL_8_0=%WLNMP_ROOT_DIR%\hub\mysql_8_0"
set "WLNMP_SERVICE_PHP_7_1=%WLNMP_ROOT_DIR%\hub\php_7_1"
set "WLNMP_SERVICE_PHP_7_2=%WLNMP_ROOT_DIR%\hub\php_7_2"
set "WLNMP_SERVICE_PHP_7_3=%WLNMP_ROOT_DIR%\hub\php_7_3"
set "WLNMP_SERVICE_PHP_7_4=%WLNMP_ROOT_DIR%\hub\php_7_4"
set "WLNMP_SERVICE_PHP_8_2=%WLNMP_ROOT_DIR%\hub\php_8_2"
set "WLNMP_SERVICE_REDIS=%WLNMP_ROOT_DIR%\hub\redis"
set "WLNMP_SERVICE_MEMCACHED=%WLNMP_ROOT_DIR%\hub\memcached"

REM 6. 初始化 docker compose 指令
set "DOCKER_COMMAND=docker compose --project-directory %WLNMP_ROOT_DIR% -f %WLNMP_SERVICE_BASE%\docker-compose.yml --env-file %WLNMP_SERVICE_BASE%\.base.env -f %WLNMP_SERVICE_NGINX%\docker-compose.yml -f %WLNMP_SERVICE_MYSQL_5_7%\docker-compose.yml -f %WLNMP_SERVICE_MYSQL_8_0%\docker-compose.yml -f %WLNMP_SERVICE_PHP_7_1%\docker-compose.yml -f %WLNMP_SERVICE_PHP_7_2%\docker-compose.yml -f %WLNMP_SERVICE_PHP_7_3%\docker-compose.yml -f %WLNMP_SERVICE_PHP_7_4%\docker-compose.yml -f %WLNMP_SERVICE_PHP_8_2%\docker-compose.yml -f %WLNMP_SERVICE_REDIS%\docker-compose.yml -f %WLNMP_SERVICE_MEMCACHED%\docker-compose.yml"

REM 7. 判断每个 service 对应的 env 文件是否存在
set "BASE_ENV_FILE=%WLNMP_SERVER_DIR%\base\.base.env"
if exist "%BASE_ENV_FILE%" (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! --env-file %BASE_ENV_FILE%"
)
set "NGINX_ENV_FILE=%WLNMP_SERVER_DIR%\nginx\.nginx.env"
if exist "%NGINX_ENV_FILE%" (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! --env-file %NGINX_ENV_FILE%"
)
set "DOCKER_COMMAND=!DOCKER_COMMAND! --env-file %WLNMP_SERVICE_MYSQL_5_7%\.env"
set "MYSQL_5_7_ENV_FILE=%WLNMP_SERVER_DIR%\mysql_5_7\.mysql_5_7.env"
if exist "%MYSQL_5_7_ENV_FILE%" (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! --env-file %MYSQL_5_7_ENV_FILE%"
)
set "DOCKER_COMMAND=!DOCKER_COMMAND! --env-file %WLNMP_SERVICE_MYSQL_8_0%\.env"
set "MYSQL_8_0_ENV_FILE=%WLNMP_SERVER_DIR%\mysql_8_0\.mysql_8_0.env"
if exist "%MYSQL_8_0_ENV_FILE%" (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! --env-file %MYSQL_8_0_ENV_FILE%"
)
set "REDIS_ENV_FILE=%WLNMP_SERVER_DIR%\redis\.redis.env"
if exist "%REDIS_ENV_FILE%" (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! --env-file %REDIS_ENV_FILE%"
)
set "DOCKER_COMMAND=!DOCKER_COMMAND! --env-file %WLNMP_SERVICE_MEMCACHED%\.env"
set "MEMCACHED_ENV_FILE=%WLNMP_SERVER_DIR%\memcached\.memcached.env"
if exist "%MEMCACHED_ENV_FILE%" (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! --env-file %MEMCACHED_ENV_FILE%"
)

REM 8.1 判断 nginx 的 env 文件中是否存在 NGINX_HTTP_PORT 和 NGINX_HTTPS_PORT
set "NGINX_HTTP_PORT="
set "NGINX_HTTPS_PORT="
if exist "%NGINX_ENV_FILE%" (
    for /f "usebackq tokens=1* delims== eol=#" %%a in ("%NGINX_ENV_FILE%") do (
        if "%%a"=="" (
            REM 跳过空行
        ) else if /i "%%a"=="NGINX_HTTP_PORT" (
            set "NGINX_HTTP_PORT=%%b"
        ) else if /i "%%a"=="NGINX_HTTPS_PORT" (
            set "NGINX_HTTPS_PORT=%%b"
        )
    )
)

if defined NGINX_HTTP_PORT (
    if defined NGINX_HTTPS_PORT (
        set "DOCKER_COMMAND=!DOCKER_COMMAND! -f %WLNMP_SERVICE_NGINX%\docker-compose.ports.yml"
    ) else (
        set "DOCKER_COMMAND=!DOCKER_COMMAND! -f %WLNMP_SERVICE_NGINX%\docker-compose.port-80.yml"
    )
) else if defined NGINX_HTTPS_PORT (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! -f %WLNMP_SERVICE_NGINX%\docker-compose.port-443.yml"
)

REM 8.2 判断 mysql 的 env 文件中是否存在 MYSQL_x_x_HOST_PORT
set "MYSQL_5_7_HOST_PORT="
if exist "%MYSQL_5_7_ENV_FILE%" (
    for /f "usebackq tokens=1* delims== eol=#" %%a in ("%MYSQL_5_7_ENV_FILE%") do (
        if "%%a"=="" (
            REM 跳过空行
        ) else if /i "%%a"=="MYSQL_5_7_HOST_PORT" (
            set "MYSQL_5_7_HOST_PORT=%%b"
        )
    )
)
if defined MYSQL_5_7_HOST_PORT (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! -f %WLNMP_SERVICE_MYSQL_5_7%\docker-compose.port-3306.yml"
)

set "MYSQL_8_0_HOST_PORT="
if exist "%MYSQL_8_0_ENV_FILE%" (
    for /f "usebackq tokens=1* delims== eol=#" %%a in ("%MYSQL_8_0_ENV_FILE%") do (
        if "%%a"=="" (
            REM 跳过空行
        ) else if /i "%%a"=="MYSQL_8_0_HOST_PORT" (
            set "MYSQL_8_0_HOST_PORT=%%b"
        )
    )
)
if defined MYSQL_8_0_HOST_PORT (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! -f %WLNMP_SERVICE_MYSQL_8_0%\docker-compose.port-3306.yml"
)

set "REDIS_HOST_PORT="
if exist "%REDIS_ENV_FILE%" (
    for /f "usebackq tokens=1* delims== eol=#" %%a in ("%REDIS_ENV_FILE%") do (
        if "%%a"=="" (
            REM 跳过空行
        ) else if /i "%%a"=="REDIS_HOST_PORT" (
            set "REDIS_HOST_PORT=%%b"
        )
    )
)
if defined REDIS_HOST_PORT (
    set "DOCKER_COMMAND=!DOCKER_COMMAND! -f %WLNMP_SERVICE_REDIS%\docker-compose.port-6379.yml"
)

REM 9. 拼接 docker-compose.bat 后面的参数并执行命令
set "DOCKER_COMMAND=!DOCKER_COMMAND! %*"
echo 执行命令：%DOCKER_COMMAND%

%DOCKER_COMMAND%

endlocal
