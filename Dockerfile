FROM openresty/openresty:1.13.6.2-0-xenial

ENV REDIS_IP REDIS_IP
ENV REDIS_PORT REDIS_PORT

# Copy lua files
COPY redis_iresty.lua /usr/local/openresty/lualib/resty/redis_iresty.lua
COPY redis_pool.lua /usr/local/openresty/lualib/resty/redis_pool.lua

COPY ./openresty-mq /etc/openresty-mq

ADD up.sh /etc/openresty-mq
RUN chmod -R 777 /etc/openresty-mq/up.sh

CMD ["/etc/openresty-mq/up.sh"]

EXPOSE 8899

STOPSIGNAL SIGQUIT

WORKDIR /etc/openresty-mq

#防docker容器自动退出
ENTRYPOINT tail -f /dev/null