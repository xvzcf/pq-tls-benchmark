#!/bin/bash
set -x

# Stop nginx in case we sent
# SIGKILL to run.sh
ip netns exec srv_ns ../tmp/nginx/sbin/nginx -s stop

##########################
# Remove s_timer
##########################
rm s_timer.o

##########################
# Remove network namespaces
##########################
ip netns del cli_ns
ip netns del srv_ns
