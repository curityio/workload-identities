#!/bin/bash

#####################################
# Deploy API client and API workloads
#####################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create the namespace for applications
#
kubectl create namespace applications 2>/dev/null

#
# Deploy the client
#
./client/deploy.sh
