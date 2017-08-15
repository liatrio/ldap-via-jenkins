#!/bin/bash
workspace=$(dirname 0)

terraform destroy -force $workspace

exit $EXIT_STATUS
