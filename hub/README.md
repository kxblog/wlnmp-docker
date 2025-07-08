## Composer2

### 使用方法

```shell
# 一次性运行
docker-compose.bat/sh run --rm composer2 composer install||update||require||... -d /app
# 进入容器内执行
docker-compose.bat/sh run -it composer2 bash
```

## PHP

### 推荐debian基础镜像版本

> 原因：alpine镜像不支持pcntl扩展

## NGINX

### 转发websocket请求

```nginx
# WebSocket 转发配置
location /ws/ {
    proxy_pass http://php_7_4:8282;  # 替换为容器名或IP+端口
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 86400s;
    # proxy_write_timeout 86400s;
    proxy_send_timeout 86400s;
    
    proxy_set_header Host $host;
}
```