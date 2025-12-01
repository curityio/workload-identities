#!/bin/bash

##########################################################################
# Do the work of deploying cert-manager and creating an upstream authority
##########################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Deploy cert-manager
#
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --wait
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create the upstream authority for SPIRE
#
kubectl -n cert-manager apply -f upstream-authority.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
