#!/bin/bash

###################################
# Deploy the Curity Identity Server
###################################

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
# Deploy runtime secrets
#
kubectl -n curity delete secret idsvr-secrets 2>/dev/null
kubectl -n curity create secret generic idsvr-secrets \
  --from-literal="ADMIN_PASSWORD=Password1" \
  --from-literal="LICENSE_KEY=$LICENSE_KEY"

#
# Run the Helm Chart to deploy the system
#
helm repo add curity https://curityio.github.io/idsvr-helm
helm repo update
helm upgrade --install curity curity/idsvr \
    --namespace curity \
    --values=idsvr/values.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered running the Helm Chart for the Curity Identity Server'
  exit 1
fi
