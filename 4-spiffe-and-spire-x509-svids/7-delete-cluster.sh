#!/bin/bash

#########################
# Delete the KIND cluster
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"

../resources/cluster/delete.sh
