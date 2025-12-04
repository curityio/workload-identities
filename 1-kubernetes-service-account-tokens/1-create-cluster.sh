#!/bin/bash

#########################
# Create the KIND cluster
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create the cluster
#
../resources/cluster/create.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Enable internal OIDC discovery to get the signing keys for Kubernetes service account tokens
#
kubectl apply -f cluster/oidc-discovery.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
