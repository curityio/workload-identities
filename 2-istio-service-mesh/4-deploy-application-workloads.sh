#!/bin/bash

##################################
# Deploy a client and API workload
##################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create the namespace for applications
#
kubectl create namespace applications 2>/dev/null

#
# Deploy the client
#
./client/deploy.sh
