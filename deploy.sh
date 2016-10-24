#! /bin/bash
set -euo pipefail
: ${CRYSTAL_BIN:=crystal}

if [ $# -lt 1 ]; then
  echo "Tag name is required"
  exit 1
fi

# Build the app
mkdir -p build
${CRYSTAL_BIN} build --release -o build/rancher-autoredeploy src/rancher-autoredeploy.cr

# Login to registry
docker login -e ${DOCKER_EMAIL} -u ${DOCKER_USER} -p ${DOCKER_PASS} ${DOCKER_REGISTRY}

# Build image and push to hub
docker build -t ${DOCKER_REPOSITORY}:$1 .
docker push ${DOCKER_REPOSITORY}:$1
