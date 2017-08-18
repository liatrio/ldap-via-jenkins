#!/bin/bash

#initialize the workspace
#this is necessary for using remote state storage
terraform init -input=false

export TF_WORKSPACE=$TF_VAR_instance_name

# destroy the insatance and it's resources
terraform destroy -force

terraform workspace delete -force $TF_WORKSPACE | echo 'done'

exit $EXIT_STATUS
