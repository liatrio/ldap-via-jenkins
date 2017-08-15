#!/bin/bash

workspace=$(dirname 0)

# make a keypair
rm -f $workspace/terraform.key $workspace/terraform.key.pub
ssh-keygen -t rsa -N "" -f $workspace/terraform.key

# initialize the workspace
terraform init -input=false

# initialize the instance
terraform apply $workspace

exit $EXIT_STATUS
