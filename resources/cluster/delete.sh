#!/bin/bash

#########################
# Delete the KIND cluster
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"

kind delete cluster --name=curitydemo
