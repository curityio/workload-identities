#!/bin/bash

#######################################################
# Deploy the Istio service mesh to integrate with SPIRE
#######################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

./istio/deploy.sh
