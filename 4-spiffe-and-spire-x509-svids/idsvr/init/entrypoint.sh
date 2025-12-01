#!/bin/bash

################################################################################################
# Prepare environment variables after SPIFFE helper retrieves SVIDs
# https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-via-file/
################################################################################################

echo 'Trust init container is running SPIFFE helper ...'
./spiffe-helper
if [ $? -ne 0 ]; then
  echo 'SPIFFE helper execution failed'
  exit 1
fi

echo 'Splitting SPIFFE trust bundle into root and intermediate certificate authorities ...'
awk 'BEGIN {c=0;} /BEGIN CERT/{c++} { print > "/tmp/cert." c ".pem"}' < /svids/svid_bundle.pem
WORKLOAD_INTERMEDIATE_CA=$(cat /tmp/cert.2.pem | openssl base64 | tr -d '\n')

echo 'Writing environment variables for the main container ...'
echo "WORKLOAD_INTERMEDIATE_CA=$WORKLOAD_INTERMEDIATE_CA" > /tmp/startup-environment-variables/.env

echo 'Trust init container completed successfully'
