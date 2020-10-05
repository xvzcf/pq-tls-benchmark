#!/bin/bash
set -ex

apt update
apt install -y git \
               build-essential \
               autoconf \
               automake \
               libtool \
               ninja-build \
               libssl-dev \
               libpcre3-dev \
               wget

NGINX_VERSION=1.17.5
CMAKE_VERSION=3.18
CMAKE_BUILD=3

mkdir -p tmp
cd tmp
ROOT=$(pwd)

# Fetch all the files we need
wget https://cmake.org/files/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.${CMAKE_BUILD}-Linux-x86_64.sh
git clone --single-branch --branch pq-tls-experiment https://github.com/xvzcf/liboqs
git clone --single-branch --branch pq-tls-experiment https://github.com/xvzcf/openssl
wget nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar -zxvf nginx-${NGINX_VERSION}.tar.gz

# Install the latest CMake
mkdir cmake
sh cmake-${CMAKE_VERSION}.${CMAKE_BUILD}-Linux-x86_64.sh --skip-license --prefix=${ROOT}/cmake

# build liboqs
cd liboqs
mkdir build && cd build
${ROOT}/cmake/bin/cmake -GNinja -DCMAKE_INSTALL_PREFIX=${ROOT}/openssl/oqs ..
ninja && ninja install

# build nginx (which builds OQS-OpenSSL)
cd ${ROOT}
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
