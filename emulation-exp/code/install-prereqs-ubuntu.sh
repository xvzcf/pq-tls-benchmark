#!/bin/bash
set -ex

apt install build-essential \
            autoconf \
            automake \
            libtool \
            cmake \
            ninja-build \
            libssl-dev \
            libpcre3-dev \
            wget;

NGINX_VERSION=1.17.5

mkdir -p tmp && cd tmp
ROOT=$(pwd)

git clone --single-branch --branch pq-tls-experiment https://github.com/xvzcf/liboqs
git clone --single-branch --branch pq-tls-experiment https://github.com/xvzcf/openssl

# build liboqs
cd liboqs
mkdir build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=${ROOT}/openssl/oqs ..
ninja && ninja install

# build nginx (which builds OQS-OpenSSL)
cd ${ROOT}
wget nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar -zxvf nginx-${NGINX_VERSION}.tar.gz;
cd nginx-${NGINX_VERSION}
./configure --prefix=${ROOT}/nginx \
                --with-debug \
                --with-http_ssl_module --with-openssl=${ROOT}/openssl \
                --without-http_gzip_module \
                --with-cc-opt="-I ${ROOT}/openssl/oqs/include" \
                --with-ld-opt="-L ${ROOT}/openssl/oqs/lib";
sed -i 's/libcrypto.a/libcrypto.a -loqs/g' objs/Makefile;
sed -i 's/EVP_MD_CTX_create/EVP_MD_CTX_new/g; s/EVP_MD_CTX_destroy/EVP_MD_CTX_free/g' src/event/ngx_event_openssl.c;
make && make install;
