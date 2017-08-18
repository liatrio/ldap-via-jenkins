#!/bin/bash

workspace=$(dirname 0)

# initialize the workspace
#this is necessary for using remote state storage
terraform init -input=false

#create workspace
export TF_WORKSPACE=$TF_VAR_instance_name

#create and switch to a new workspace
terraform workspace new $TF_VAR_instance_name

# initialize the instance
terraform apply $workspace

exit $EXIT_STATUS
