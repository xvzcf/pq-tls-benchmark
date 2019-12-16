#!/bin/bash

ROOT="$(dirname $(pwd))"
NGINX_APP=${ROOT}/tmp/nginx/sbin/nginx

##########################
# Stop nginx
##########################
ip netns exec srv_ns ${NGINX_APP} -s stop

##########################
# Remove files
##########################
rm -f prime256v1.pem \
      s_timer.o

##########################
# Remove network namespaces
##########################
ip netns del cli_ns
ip netns del srv_ns
