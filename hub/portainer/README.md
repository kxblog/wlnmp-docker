### 使用方法

1. 安装运行方式：
- 原生命令：`docker volume create portainer_data`, `docker compose up -d -p 9443:9443 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data`
- wlnmp命令: 配置 `wlnmp.bat/sh` 内端口, `wlnmp.bat/sh up -d`
2. 浏览器打开 `https://localhost:xxxx(默认:9443)` 访问容器
3. 初始化管理员账号密码

#### Windows

1. [重要]启用 "Expose daemon on tcp://localhost:2375 without TLS"（设置 > Resources > WSL Integration）
2. 侧边菜单 `Environment` -> `Add Environments` -> 选择 `Docker Standalone` Start Wizard -> 选择 `API` -> 填写 `Name: localhost`, `Docker API URL: host.docker.internal:2375` -> Connect。