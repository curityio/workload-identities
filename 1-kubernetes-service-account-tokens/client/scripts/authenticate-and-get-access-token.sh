#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

##################################################################################
# A script to test getting an access token using a Kubenetes service account token
##################################################################################

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

echo 'Using JWT workload credential to authenticate and get an access token ...'
JWT_ASSERTION="$(cat /var/run/secrets/kubernetes.io/serviceaccount/assertion)"
jwt_header  "$JWT_ASSERTION" | jq
jwt_payload "$JWT_ASSERTION" | jq

HTTP_STATUS=$(curl -s -X POST http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-token \
     -H 'Content-Type: application/x-www-form-urlencoded' \
     -d 'grant_type=client_credentials' \
     -d "client_assertion=$JWT_ASSERTION" \
     -d 'client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer' \
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
