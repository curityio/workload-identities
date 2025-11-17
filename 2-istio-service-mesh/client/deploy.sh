#!/bin/bash

####################################
# Deploy the example client workload
####################################

cd "$(dirname "${BASH_SOURCE[0]}")"

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
kubectl -n applications apply  -f client.yaml
