#!/bin/bash
set -x

ROOT="$(dirname $(pwd))"

NGINX_APP=${ROOT}/tmp/nginx/sbin/nginx
NGINX_CONF_DIR=${ROOT}/tmp/nginx/conf

ip netns exec srv_ns ${NGINX_APP} -s stop

##########################
# Run experiment
##########################
set -e

for SIG in "ecdsap256" "dilithium2" "qteslapi" "picnicl1fs";
do
    # Ask nginx to use ${SIG} cert and key
    sed "s/??SERVER_CERT??/${SIG}_server.crt/g; s/??SERVER_KEY??/${SIG}_server.key/g" nginx.conf > ${NGINX_CONF_DIR}/nginx.conf

    # Start nginx
    ip netns exec srv_ns ${NGINX_APP}

    # Run experiment
    python3 experiment.py ${SIG}

    # Stop nginx
    ip netns exec srv_ns ${NGINX_APP} -s stop

    # Wait a bit before restarting
    sleep 5
done
