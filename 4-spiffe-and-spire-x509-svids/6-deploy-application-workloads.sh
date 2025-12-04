#!/bin/bash

##############################
# Deploy application workloads
##############################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create the namespace for applications
#
kubectl create namespace applications 2>/dev/null

#
# Deploy the client workload
#
../resources/spiffe-client/deploy.sh 'x509'
