#!/bin/bash

###########################################
# Deploy SPIRE to issue workload identities
###########################################

cd "$(dirname "${BASH_SOURCE[0]}")"

./spire/deploy.sh
