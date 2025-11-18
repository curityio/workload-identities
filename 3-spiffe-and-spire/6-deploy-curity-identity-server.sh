#!/bin/bash

###########################################################
# Deploy the Curity Identity Server to integrate with SPIRE
###########################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

./curity/deploy.sh
