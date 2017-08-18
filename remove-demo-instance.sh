#!/bin/bash

#initialize the workspace
#this is necessary for using remote state storage
terraform init -input=false

# destroy the insatance and it's resources
terraform destroy -force

terraform workspace delete $TF_STATE -force

exit $EXIT_STATUS
