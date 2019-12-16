#!/bin/bash
set -ex

apt install build-essential \
            autoconf \
            automake \
            libtool \
            libssl-dev \
            libpcre3-dev \
            wget;

NGINX_VERSION=1.17.5

mkdir -p tmp && cd tmp
ROOT=$(pwd)

git clone --single-branch --branch oqs-optimized https://github.com/open-quantum-safe/liboqs liboqs
git clone --single-branch --branch oqs-ossl-111-optimized https://github.com/open-quantum-safe/openssl openssl

# build liboqs
cd liboqs
autoreconf -i
./configure --prefix=${ROOT}/openssl/oqs --enable-shared=no
make -j
make install;

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
