#!/bin/bash

######################################################
# Deploy a utility workload that uses SPIFFE and SPIRE
######################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Use the advanced values file when using SPIRE integration
#
if [ "$1" == 'x509' ]; then
  CLIENT_DEPLOYMENT='x509-client.yaml'
else
  CLIENT_DEPLOYMENT='jwt-client.yaml'
fi

#
# Download the SPIFFE helper binary for Linux and unpack it
#
VERSION='v0.11.0'
curl -s -L "https://github.com/spiffe/spiffe-helper/releases/download/$VERSION/spiffe-helper_${VERSION}_Linux-x86_64.tar.gz" > spiffe-helper.tar.gz
if [ $? -ne 0 ]; then
  exit 1
fi
tar xf spiffe-helper.tar.gz

#
# Build the client workload and load it into the KIND registry
#
docker build --no-cache -t client:1.0 .
if [ $? -ne 0 ]; then
  exit 1
fi

kind load docker-image client:1.0 --name curitydemo
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the client workload
#
kubectl -n applications apply -f "$CLIENT_DEPLOYMENT"
if [ $? -ne 0 ]; then
  exit 1
fi
