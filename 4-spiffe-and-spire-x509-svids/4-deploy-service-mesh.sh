#!/bin/bash

#######################################################
# Deploy the Istio service mesh to integrate with SPIRE
#######################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/service-mesh/deploy.sh 'spire'
