#!/bin/bash

set -x

sed -i "s/= REDIS_IP/= '${REDIS_IP}'/g" /etc/openresty-mq/conf/lua/conf.lua
sed -i "s/= REDIS_PORT/= ${REDIS_PORT}/g" /etc/openresty-mq/conf/lua/conf.lua

./start.sh

while true; do sleep 30; done;
