#!/bin/bash

###################################################################
# Update the Curity Identity Server when SPIFFE helper renews SVIDs
###################################################################

echo 'Trust sidecar container successfully retrieved SVIDs'

#
# The sidecar uses the local loopback URL to call the RESTCONF API
#
RESTCONF_BASE_URL='http://127.0.0.1:6749/admin/api/restconf/data'
ADMIN_USER='admin'
ADMIN_PASSWORD='Password1'

#
# Exit if the main admin container is not ready yet
#
echo 'Checking connectivity for the RESTCONF API ...'
HTTP_STATUS=$(curl -s "$RESTCONF_BASE_URL" \
    -u "$ADMIN_USER:$ADMIN_PASSWORD" \
    -o /tmp/response.txt -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo 'Exiting because the RESTCONF API is not yet available'
  exit 1
fi

#
# Get new trust stores
#
echo 'Splitting SPIFFE trust bundle into root and intermediate certificate authorities ...'
awk 'BEGIN {c=0;} /BEGIN CERT/{c++} { print > "/tmp/cert." c ".pem"}' < /svids/svid_bundle.pem
WORKLOAD_INTERMEDIATE_CA=$(cat /tmp/cert.2.pem | openssl base64 | tr -d '\n')

#
# Update the client trust store
#
HTTP_STATUS=$(curl -s -X POST "$RESTCONF_BASE_URL/base:facilities/crypto/add-ssl-client-truststore" \
    -u "$ADMIN_USER:$ADMIN_PASSWORD" \
    -H 'Content-Type: application/yang-data+json' \
    -d "{\"id\":\"workload_intermediate_ca\",\"keystore\":\"$WORKLOAD_INTERMEDIATE_CA\"}" \
    -o /tmp/response.txt -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "Problem encountered updating the client trust store for the SPIFFE intermediate CA: $HTTP_STATUS"
  exit 1
fi
