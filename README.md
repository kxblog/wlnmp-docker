# WLNMP Docker 环境

`WLNMP` 是一个基于 `docker` 的开发环境一键安装包。他可以通过简单配置，与 `docker compose` 命令相同的方式，构建并启动 `nginx`、`php`、`mysql`、`redis` 等环境。

## **`docker-compose.bat/sh` 开发环境构建运行脚本**

#### 脚本说明

`docker-compose.bat/sh` 是一个用于在 Windows/Linux 环境中，通过与 `docker compose` 一致的命令格式，构建和启动容器的脚本。

#### 目录结构
```
.
├── wlnmp.bat/sh (控制面板脚本文件)
├── docker-compose.bat/sh (脚本文件)
├── {WLNMP_SERVER_NAME} (服务目录-配置开发环境服务目录)
│   ├── .{WLNMP_SERVER_NAME}.env (WLNMP_WWW_DIR项目运行目录)
│   ├── {WLNMP_SERVER_NAME}.bat/sh (服务配置及启动脚本)
│   ├── {serer} (具体的服务目录)
│   │   ├──.{server}.env (服务配置文件)
│   ├── nginx
│   │   ├── conf.d
│   │   │   ├── html.conf
│   │   │   ├── php.conf
│   │   ├── .nginx.env
│   ├── php{version}
│   │   ├── conf.d
│   │   │   ├── empty.ini
│   │   ├── php-fpm.d
│   │   │   ├── empty.conf
│   ├── mysql{version}
│   │   ├── conf.d
│   │   │   ├── encoding.cnf
│   │   │   ├── timestamp.cnf
│   │   ├── .mysql{version}.env
│   ├── redis
│   │   ├── .redis.env
│   ├── frpc
│   │   ├── frpc.toml
│   ├── frps
│   │   ├── frps.toml
│   ├── ...
├── ...
```

#### 使用方法

1. 添加执行权限 `chmod +x docker-compose.sh`
2. 配置 `.env` 文件：
    `WLNMP_SERVER_NAME` 为开发环境的服务名称及目录名，同时也会作为 `docker-compose.yml` 中的服务名称。
3. 按需配置开发环境相关服务，`{WLNMP_SERVER_NAME}/{WLNMP_SERVER_NAME}.bat/sh` 文件：
    如 `nginx`、`php`、`mysql`、`redis` 等配置文件或映射端口。
4. 调整 `{WLNMP_SERVER_NAME}/.{WLNMP_SERVER_NAME}.env` 文件，主要配置 `WLNMP_WWW_DIR` 目录。
5. `docker-compose.bat/sh up -d` 启动容器
6. 按需执行 `docker-compose.bat/sh exec {service} {command}` 执行容器内命令。
7. 按需执行 `docker-compose.bat/sh run --rm {service} {command}` 执行容器内命令，并自动删除容器。

## **`wlnmp.bat/sh` Web 端 Docker 管理面板脚本**

#### 脚本说明

`wlnmp.bat/sh` 是一个用于在 Windows/Linux 环境中通过浏览器管理 docker 容器的脚本。他预装了 `portainer` 容器，并且可以通过浏览器访问容器。

#### 使用方法

1. 添加执行权限 `chmod +x wlnmp.sh`
2. 修改 `wlnmp.bat` 文件中的端口
3. `wlnmp.bat up -d` 启动容器
4. 浏览器打开 `https://localhost:xxxx(默认:9443)` 访问容器
5. 初始化管理员账号密码
6. **Windows** 侧边菜单 `Environment` -> `Add Environments` -> 选择 `Docker Standalone` Start Wizard -> 选择 `API` -> 填写 `Name: localhost`, `Docker API URL: host.docker.internal:2375` -> Connect

**Windows 中 Docker Desktop 前置条件**

1. 启用 "Expose daemon on tcp://localhost:2375 without TLS"（设置 > Resources > WSL Integration）
2. 启用 "Use WSL 2 based engine"（设置 > General）

## **最佳实践**

#### Windows 中 Docker Desktop 的配置

**常见问题**

> 官方文档：在 WSL 中使用 Linux 工具访问项目文件时，将项目文件存储在 Windows 文件系统上会明显降低速度。

| 挂载方式	| 性能	| 适用场景 |
|---|---|---|
|WSL 2 内路径（如 /www/project）|	✅ 高	|开发环境（推荐）|
|Windows 路径（如 C:/...）|	❌ 低	|临时测试|

**推荐配置**

1. 安装 WSL2 （Windows Subsystem for Linux）（通过wsl --update更新）
2. 启用 "Use WSL 2 based engine"（设置 > General）
3. 安装 WSL2 Linux 发行版（推荐使用 Ubuntu 或 Debian 等 Linux 发行版）
4. 在 Resources > WSL Integration 中启用你的 WSL 发行版（如 Ubuntu 或 Debian 等 Linux 发行版）
5. 用户权限：（如果在WSL终端中使用docker命令，则需要）
5.1 在 WSL 终端中，确保当前用户已加入 docker 组，运行 `sudo usermod -aG docker $USER`
5.2 重启 WSL 环境使权限生效，运行 `wsl --shutdown` 后重新打开 WSL 终端