FROM node:22-alpine

# 备份原始 repositories 文件
RUN cp /etc/apk/repositories /etc/apk/repositories.bak; \
    # sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories; \
    # 修改 repositories 文件为阿里云镜像源
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    # 设置中国镜像源
    npm config set registry https://registry.npmmirror.com; \
    # 安装pnpm
    npm install -g pnpm;

# 添加保持容器运行的命令（放在最后作为默认命令）
CMD ["tail", "-f", "/dev/null"]