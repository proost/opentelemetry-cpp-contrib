#!/bin/bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

GRPC_VERSION=v1.66.0
OPENTELEMETRY_CPP_VERSION=v1.22.0

apt-get update

apt-get install --no-install-recommends --no-install-suggests -y \
   build-essential autoconf libtool pkg-config ca-certificates gcc g++ git \
   libcurl4-openssl-dev libpcre3-dev gnupg2 lsb-release curl apt-transport-https \
   software-properties-common zlib1g-dev

curl -o /etc/apt/trusted.gpg.d/kitware.asc https://apt.kitware.com/keys/kitware-archive-latest.asc
apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"

apt-get install --no-install-recommends --no-install-suggests -y \
   cmake libboost-all-dev

git clone --shallow-submodules --depth 1 --recurse-submodules -b "$GRPC_VERSION" \
   https://github.com/grpc/grpc
mkdir -p grpc/cmake/build
cd grpc/cmake/build
cmake \
   -DgRPC_INSTALL=ON \
   -DgRPC_BUILD_TESTS=OFF \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_CXX_STANDARD=14 \
   -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
   -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
   -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
   -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
   -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
   -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
   ../..
make -j"$(nproc)"
make install
cd -

git clone --shallow-submodules --depth 1 --recurse-submodules -b "$OPENTELEMETRY_CPP_VERSION" \
   https://github.com/open-telemetry/opentelemetry-cpp.git
mkdir -p opentelemetry-cpp/build
cd opentelemetry-cpp/build
cmake \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_CXX_STANDARD=14 \
   -DWITH_OTLP_GRPC=ON \
   -DBUILD_TESTING=OFF \
   -DWITH_EXAMPLES=OFF \
   -DWITH_BENCHMARK=OFF \
   -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
   ..
make -j"$(nproc)"
make install
cd -
