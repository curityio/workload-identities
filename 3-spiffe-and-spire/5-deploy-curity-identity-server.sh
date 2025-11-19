#!/bin/bash

###########################################################
# Deploy the Curity Identity Server to integrate with SPIRE
###########################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Check for a license file before allowing deployment
#
if [ "$LICENSE_FILE_PATH" == '' ]; then
  echo 'Please provide a LICENSE_FILE_PATH environment variable with the path to a Curity Identity Server license file.'
  exit 1
fi

LICENSE_KEY=$(cat "$LICENSE_FILE_PATH" | jq -r .License)
if [ "$LICENSE_KEY" == '' ]; then
  echo 'An invalid license file was provided for the Curity Identity Server'
  exit 1
fi

#
# Prevent accidental check-ins of license files
#
cp ../hooks/pre-commit ../.git/hooks

#
# Build the Docker image for this deployment
#
./idsvr/build.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create the namespace and service accounts, and require mTLS to call workloads
#
kubectl create namespace curity 2>/dev/null
kubectl -n curity apply -f ../resources/idsvr/service-accounts.yaml
kubectl -n curity apply -f ../resources/idsvr/mtls.yaml

#
# Configure the cert-manmager root CA as a trust store
# This enables the Curity Identity Server to call the SPIFFE JWKS URI without trust errors
#
export WORKLOAD_ROOT_CA="$(kubectl -n cert-manager get secret/rootca-secret -o jsonpath='{.data.ca\.crt}')"
if [ "$WORKLOAD_ROOT_CA" == '' ]; then
  echo 'Unable to get the cert-manager root CA'
  exit 1
fi

#
# Deploy runtime secrets
#
kubectl -n curity delete secret idsvr-secrets 2>/dev/null
kubectl -n curity create secret generic idsvr-secrets \
  --from-literal="ADMIN_PASSWORD=Password1" \
  --from-literal="LICENSE_KEY=$LICENSE_KEY" \
  --from-literal="WORKLOAD_ROOT_CA=$WORKLOAD_ROOT_CA"

#
# Use an alternative Helm values file if running the more complex deployment that uses X509 SVIDs
#
if [ "$CONFIGURE_X509_TRUST" == 'true' ]; then
  VALUES_FILE=./idsvr/x509/values.yaml
else
  VALUES_FILE=./idsvr/values.yaml
fi

#
# Run the Helm Chart to deploy the system
#
helm repo add curity https://curityio.github.io/idsvr-helm
helm repo update
helm upgrade --install curity curity/idsvr \
    --namespace curity \
    --values=$VALUES_FILE
if [ $? -ne 0 ]; then
  echo 'Problem encountered running the Helm Chart for the Curity Identity Server'
  exit 1
fi

#
# Add an envoy filter to enable clients to use X509 SVIDs for client authentication
#
if [ "$CONFIGURE_X509_TRUST" == 'true' ]; then
  kubectl -n curity apply -f idsvr/x509/client-certificate-forwarder.yaml
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi
