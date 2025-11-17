#!/bin/bash

#########################
# Deploy the service mesh
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"

./service-mesh/deploy.sh
