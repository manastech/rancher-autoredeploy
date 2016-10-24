#! /bin/bash
set -euo pipefail

docker build -f Dockerfile.builder -t manastech/rancher-autoredeploy-builder .
docker run --rm -v `pwd`/build:/build:rw manastech/rancher-autoredeploy-builder

echo "Binary for Ubuntu is in `pwd`/build/rancher-autoredeploy"
