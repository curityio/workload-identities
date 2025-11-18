#!/bin/bash

###############################
# Deploy cert-manager resources
###############################

cd "$(dirname "${BASH_SOURCE[0]}")"

./cert-manager/deploy.sh
