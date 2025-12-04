#!/bin/bash

###########################################
# Deploy SPIRE to issue workload identities
###########################################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/spire/deploy.sh
