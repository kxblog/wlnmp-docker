在大陆访问 Docker Hub 速度较慢，可以通过搭建一个 **Docker Registry 镜像代理（加速站）** 来提升镜像拉取速度。以下是几种常见方案：

---

## ✅ 方法一：使用官方推荐的 Registry Mirror（最简单）

### 步骤：

1. 编辑或创建 Docker 的配置文件（通常为 `/etc/docker/daemon.json`）：
   ```json
   {
     "registry-mirrors": ["https://<mirror-url>"]
   }
   ```

2. 使用国内镜像地址（例如阿里云、DaoCloud、七牛云等）：
   - 阿里云（需要登录控制台获取专属加速器地址）: `https://<your-id>.mirror.aliyuncs.com`
   - DaoCloud: `https://docker.m.daocloud.io`
   - 七牛云（已失效）: `https://reg-mirror.qiniu.com`

3. 示例配置：
   ```json
   {
     "registry-mirrors": ["https://docker.m.daocloud.io"]
   }
   ```

4. 重启 Docker 服务：
   ```bash
   sudo systemctl restart docker
   ```

✅ **优点**：无需额外资源，只需修改配置即可。

⚠️ **缺点**：依赖第三方服务，不能完全自控缓存内容。

---

## ✅ 方法二：部署私有 Registry 并设置为 Pull Through Cache（推荐）

使用 Docker 官方提供的 [registry](https://hub.docker.com/_/registry) 镜像，可以搭建支持缓存的代理仓库（Pull Through Cache），实现对 Docker Hub 的本地缓存。

### 步骤：

1. 创建 `config.yml` 配置文件：

```yaml
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    layerinfo: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    interval: 10s
    threshold: 3
proxy:
  remoteurl: https://registry-1.docker.io
```

2. 启动 Registry 容器：
```bash
docker run -d \
  --name registry-cache \
  -p 5000:5000 \
  -v $(pwd)/config.yml:/etc/docker/registry/config.yml \
  registry:2
```

3. 修改 Docker daemon.json，添加 mirror：
```json
{
  "registry-mirrors": ["http://localhost:5000"]
}
```

4. 重启 Docker：
```bash
sudo systemctl restart docker
```

✅ **优点**：
- 自建缓存，速度快。
- 可以缓存常用镜像。
- 支持企业级扩展，如认证、HTTPS、存储后端等。

⚠️ **缺点**：需维护基础设施。

---

## ✅ 方法三：使用 Harbor 搭建企业级镜像仓库

如果你需要完整的镜像管理能力（权限控制、扫描、复制等），可使用 [Harbor](https://goharbor.io/)。

### 特性：

- 支持 Pull Through Cache（从 Docker Hub 缓存）
- 提供 Web UI 和 API
- 支持 LDAP/AD 认证
- 支持漏洞扫描（Clair 等）

📌 官网文档：[https://goharbor.io/docs/latest/install-config/](https://goharbor.io/docs/latest/install-config/)

---

## 🧪 验证是否生效

运行以下命令测试镜像拉取速度：

```bash
docker pull nginx
```

如果看到请求到了你的本地代理地址（如 `localhost:5000` 或 `docker.m.daocloud.io`），说明加速已生效。

---

## 📌 总结

| 方案 | 是否推荐 | 适用场景 |
|------|----------|----------|
| Registry Mirror（方法一） | ✅ 推荐 | 快速搭建，适合个人开发者 |
| Pull Through Cache（方法二） | ✅✅ 强烈推荐 | 企业和团队自建缓存加速 |
| Harbor（方法三） | ✅✅✅ 极力推荐 | 企业级镜像管理 + 加速 |

---

如需进一步指导如何搭建私有 Registry 或 Harbor，请告诉我你使用的操作系统和网络环境，我可以提供详细步骤。