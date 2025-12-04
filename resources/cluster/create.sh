#!/bin/bash

#########################
# Create the KIND cluster
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"

kind create cluster --config=cluster.yaml
