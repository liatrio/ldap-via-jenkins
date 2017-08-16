#!/bin/bash

workspace=$(dirname 0)

# initialize the workspace
#this is necessary for using remote state storage
terraform init -input=false

# initialize the instance
terraform apply $workspace

exit $EXIT_STATUS
