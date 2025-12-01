#!/bin/bash

#####################################################################################
# A script to test getting an access token using a SPIFFE X509 SVID
# The example uses mTLS by proxy where the client's Istio sidecar sends the X509 SVID
#####################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

function jwt_header() {
  local _INPUT="$1"
  local _OUTPUT=$(echo "$_INPUT" | jq -R 'split(".") | .[0] | gsub("-"; "+") | gsub("_"; "/") | gsub("%3D"; "=") | @base64d | fromjson')
  echo $_OUTPUT
}

function jwt_payload() {
  local _INPUT="$1"
  local _OUTPUT=$(echo "$_INPUT" | jq -R 'split(".") | .[1] | gsub("-"; "+") | gsub("_"; "/") | gsub("%3D"; "=") | @base64d | fromjson')
  echo $_OUTPUT
}

echo 'Rendering X509 SVID workload credential:'
openssl x509 -in /svids/svid.pem -text -noout
echo 

echo 'Using X509 SVID to authenticate and get an access token ...'
HTTP_STATUS=$(curl -s -X POST http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-token \
     -H 'Content-Type: application/x-www-form-urlencoded' \
     -d 'client_id=x509_certificate_client' \
     -d 'grant_type=client_credentials' \
     -d 'scope=reports' \
     -o response.txt \
     -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "Problem encountered getting an access token, status: $HTTP_STATUS"
  cat response.txt
  exit 1
fi

echo 'Received JWT access token ...'
ACCESS_TOKEN=$(cat response.txt | jq -r .access_token)
jwt_header  "$ACCESS_TOKEN" | jq
jwt_payload "$ACCESS_TOKEN" | jq
