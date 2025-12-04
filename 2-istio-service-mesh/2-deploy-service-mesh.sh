#!/bin/bash

###############################
# Deploy the Istio service mesh
###############################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/service-mesh/deploy.sh
