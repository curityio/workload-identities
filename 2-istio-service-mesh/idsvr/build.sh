#!/bin/bash

###############################################
# Build the Curity Identity Server Docker image
###############################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Copy files to deploy to a build folder
#
rm -rf build 2>/dev/null
mkdir build
cp ../../resources/idsvr/base-configuration.xml             build/
cp ../../resources/idsvr/client_credentials_token_issuer.js build/

#
# Build the custom Docker image
#
docker build --no-cache -t custom_idsvr:1.0 .
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Load the Docker image into the KIND registry
#
kind load docker-image custom_idsvr:1.0 --name curitydemo
if [ $? -ne 0 ]; then
  exit 1
fi
