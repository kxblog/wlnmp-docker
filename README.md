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

**问题**

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

## **常见问题**

#### 1. windows重启后，docker服务无法启动,报如下错误：

> Error response from daemon: error while mounting volume '/var/lib/docker/volumes/wlnmp_www_volume/_data': failed to mount local volume: mount /run/desktop/mnt/host/wsl/docker-desktop-bind-mounts/Ubuntu/948088fd1a42b686ea7be15ddcdc8ba294ee5d38a8ab7ef920b4d4261872031b:/var/lib/docker/volumes/wlnmp_www_volume/_data, flags: 0x1000: no such file or directory
>错误：执行 /home/bobo/wlnmp-docker/wlnmp/wlnmp.sh 脚本失败，错误码 0

错误原因：

Windows + WSL2 + Docker Desktop环境中使用时，由于Docker + WSL2 路径映射机制的兼容性问题，Docker Desktop 在 WSL2 环境中运行时，它对主机路径的处理分为两个阶段(Docker Desktop默认会将WSL(Ubuntu)中的路径映射为WSL2 兼容路径)：

|阶段|路径类型|说明|
|---|---|---|
|1. 用户配置路径|/home/bobo/wwwroot|这是你在 compose 文件或环境变量里写的路径|
|2. 内部映射路径|/run/desktop/mnt/host/wsl/docker-desktop-bind-mounts/Ubuntu/<hash>:/var/lib/docker/volumes/wlnmp_www_volume/_data|Docker 自动生成的绑定路径，用于访问 WSL2 文件系统|

Docker和WSL2中间夹着Windows做路径映射处理，所以Docker内部映射路径会变成这样：

```
         ___ WSL
        /
Windows
        \___ Docker Linux VM -- Containers
```

解决办法一：

1. 停止并清理容器及数据卷
```
docker-compose.bat/sh down -v
```
2. 重新启动容器
```
docker-compose.bat/sh up -d
```

解决方法二：

1. 先查看 wlnmp_www_volume 信息 `device` 位置（如果你明确知道该数据卷之前源数据是哪里）
```
docker volume inspect wlnmp_www_volume
```
得到如下：
```
[
    {
        "CreatedAt": "2025-06-15T04:55:45Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.config-hash": "e8e55f11c0925598740ec717a63eb2c3828917d082b9563e2ca48169bc27ee5e",
            "com.docker.compose.project": "wlnmp",
            "com.docker.compose.version": "2.35.1",
            "com.docker.compose.volume": "www_volume"
        },
        "Mountpoint": "/var/lib/docker/volumes/wlnmp_www_volume/_data",
        "Name": "wlnmp_www_volume",
        "Options": {
            "device": "/home/bobo/wwwroot",
            "o": "bind",
            "type": "none"
        },
        "Scope": "local"
    }
]
```

2. 以上信息可以知道 `wlnmp_www_volume` 数据卷的源目录是 "/home/bobo/wwwroot" 目录

3. 进入 WSL2 的 `Ubuntu` 子系统手动挂载:
```
# 创建与错误信息中相同的hash目录
# sudo mkdir -p /mnt/wsl/docker-desktop-bind-mounts/Ubuntu/{hash}
sudo mkdir -p /mnt/wsl/docker-desktop-bind-mounts/Ubuntu/948088fd1a42b686ea7be15ddcdc8ba294ee5d38a8ab7ef920b4d4261872031b
# 挂载
# sudo mount --bind {device} /mnt/wsl/docker-desktop-bind-mounts/Ubuntu/{hash}
sudo mount --bind /home/bobo/wwwroot /mnt/wsl/docker-desktop-bind-mounts/Ubuntu/948088fd1a42b686ea7be15ddcdc8ba294ee5d38a8ab7ef920b4d4261872031b
```
