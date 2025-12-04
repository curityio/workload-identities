#!/bin/bash

#########################
# Create the KIND cluster
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/cluster/create.sh
