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
cp *.xml                                                    build/
cp ../../resources/idsvr/client_credentials_token_issuer.js build/

#
# Copy in extra configuration if running the more complex deployment that uses X509 SVIDs
#
if [ "$CONFIGURE_X509_TRUST" == 'true' ]; then
  cp ./x509/*.xml build/
fi

#
# Build a custom Docker image for the Curity Identity Server and load it into the KIND registry
#
docker build --no-cache -t custom_idsvr:1.0 .
if [ $? -ne 0 ]; then
  exit 1
fi

kind load docker-image custom_idsvr:1.0 --name curitydemo
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Build extra init and sidecar containers if running the more complex deployment that uses X509 SVIDs
#
if [ "$CONFIGURE_X509_TRUST" == 'true' ]; then
  
  ./x509/init/build.sh
  if [ $? -ne 0 ]; then
    exit 1
  fi
  ./x509/update/build.sh
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

