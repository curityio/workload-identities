#!/bin/bash

##########################################################################
# Do the work of deploying cert-manager and creating an upstream authority
##########################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Get the Helm resources
#
helm repo add spire https://spiffe.github.io/helm-charts-hardened/
helm repo update

#
# Deploy custom resource definitions
#
helm upgrade --install spire-crds spire-crds \
  --namespace spire-server \
  --create-namespace \
  --repo https://spiffe.github.io/helm-charts-hardened/
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy SPIRE server components
#
helm upgrade --install spire spire \
  --namespace spire-server \
  --repo https://spiffe.github.io/helm-charts-hardened/ \
  --values=values.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
