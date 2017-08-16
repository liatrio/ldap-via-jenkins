#!/bin/bash
workspace=$(dirname 0)

#initialize the workspace
#this is necessary for using remote state storage
terraform init -input=false

# destry the insatnce and it's resources
terraform destroy -force $workspace

exit $EXIT_STATUS
