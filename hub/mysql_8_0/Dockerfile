FROM mysql:8.0-debian

# 新增入口脚本（在文件末尾添加）
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["mysqld"]