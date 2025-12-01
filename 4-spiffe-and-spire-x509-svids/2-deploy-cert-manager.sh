#!/bin/bash

########################################################
# Deploy cert-manager as an upstream authority for SPIRE
########################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/cert-manager/deploy.sh
