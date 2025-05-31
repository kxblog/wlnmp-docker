FROM nginx:alpine

# 新增入口脚本（在文件末尾添加）
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 保持原有 CMD 指令
CMD ["nginx", "-g", "daemon off;"]