#!/bin/bash

################################
# Deploy the API client workload
################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Get Helm charts
#
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
ISTIO_VERSION='1.28.0'

#
# Install the Istio base system with custom resource definitions
#
echo 'Installing the Istio base system ...'
helm upgrade --install istio-base istio/base \
  --namespace istio-system \
  --create-namespace \
  --version "$ISTIO_VERSION" \
  --wait
if [ $? -ne 0 ]; then
  echo 'Problem encountered Istio base system'
  exit 1
fi

#
# Install istiod, which manages sidecar injection
#
echo 'Installing istiod ...'
helm upgrade --install istiod istio/istiod \
  --namespace istio-system \
  --values=istiod-values.yaml \
  --version "$ISTIO_VERSION" \
  --wait
if [ $? -ne 0 ]; then
  echo 'Problem encountered installing istiod'
  exit 1
fi
