FROM node:12.22.12-alpine

# 设置中国镜像源
RUN npm config set registry https://registry.npmmirror.com

# 添加保持容器运行的命令（放在最后作为默认命令）
CMD ["tail", "-f", "/dev/null"]

# 安装依赖时指定旧版 npm
# npm install --legacy-peer-deps