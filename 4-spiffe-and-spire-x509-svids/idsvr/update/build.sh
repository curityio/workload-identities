#!/bin/bash

#############################################################################################
# Build a container that runs SPIFFE helper in daemon mode and calls the RESTCONF API
# This keeps the SPIRE intermediate CA configuration up to date in the Curity Identity Server
#############################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

echo 'Building the trust update container ...'

VERSION='v0.11.0'
curl -s -L "https://github.com/spiffe/spiffe-helper/releases/download/$VERSION/spiffe-helper_${VERSION}_Linux-x86_64.tar.gz" > spiffe-helper.tar.gz
if [ $? -ne 0 ]; then
  exit 1
fi

tar xf spiffe-helper.tar.gz
if [ $? -ne 0 ]; then
  exit 1
fi

docker build --no-cache -t trust_update:1.0 .
if [ $? -ne 0 ]; then
  exit 1
fi

kind load docker-image trust_update:1.0 --name curitydemo
if [ $? -ne 0 ]; then
  exit 1
fi
