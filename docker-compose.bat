@echo off
REM 注意：该文件必须以 UTF-8 编码保存
rem 设置编码为 UTF-8
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 设置 WLNMP_ROOT_DIR 为 docker-compose.bat 脚本所在目录
set "WLNMP_ROOT_DIR=%~dp0"
REM 去除路径末尾的反斜杠
set "WLNMP_ROOT_DIR=%WLNMP_ROOT_DIR:~0,-1%"

REM 检查.env文件是否存在
if not exist ".env" (
    echo 错误：当前目录缺少 .env 文件
    exit /b 1
)

REM 从.env读取WLNMP_SERVER_NAME配置（增强版）
set "WLNMP_SERVER_NAME="
for /f "tokens=1,* delims==" %%a in ('findstr /i "^[^#]*WLNMP_SERVER_NAME=" ".env"') do (
    for /f "tokens=* delims= " %%c in ("%%a") do set "var_name=%%c"
    for /f "tokens=* delims= " %%d in ("%%b") do set "var_value=%%d"
    if "!var_name!"=="WLNMP_SERVER_NAME" if not "!var_value!"=="" (
        set "WLNMP_SERVER_NAME=!var_value!"
        goto :env_check_pass
    )
)

REM 如果未找到有效配置
echo 错误：.env 文件中缺少 WLNMP_SERVER_NAME 配置
exit /b 1

:env_check_pass

REM 拼接 WLNMP_SERVER_DIR 的值
set "WLNMP_SERVER_DIR=%WLNMP_ROOT_DIR%\%WLNMP_SERVER_NAME%"

REM 记录用户执行 docker-compose.bat 时的原始目录
set "ORIGINAL_DIR=%CD%"

REM 判断 WLNMP_SERVER_DIR 目录下的 WLNMP_SERVER_NAME.bat 文件是否存在
if not exist "%WLNMP_SERVER_DIR%\%WLNMP_SERVER_NAME%.bat" (
    echo 错误：%WLNMP_SERVER_DIR%\%WLNMP_SERVER_NAME%.bat 文件不存在。
    exit /b 1
)

REM 切换到 WLNMP_ROOT_DIR 目录
cd /d "%WLNMP_ROOT_DIR%"

REM 输出要执行的脚本路径和参数，方便调试
echo 即将执行脚本："%WLNMP_SERVER_DIR%\%WLNMP_SERVER_NAME%.bat" %*

REM 执行 WLNMP_SERVER_NAME.bat 脚本并传递所有参数
call "%WLNMP_SERVER_DIR%\%WLNMP_SERVER_NAME%.bat" %*
if errorlevel 1 (
    echo 错误：执行 %WLNMP_SERVER_DIR%\%WLNMP_SERVER_NAME%.bat 脚本失败。
    exit /b 1
)

REM 切换回原来用户执行 docker-compose.bat 时的目录
cd /d "%ORIGINAL_DIR%"

REM 清除临时环境变量
set "ORIGINAL_DIR="
endlocal