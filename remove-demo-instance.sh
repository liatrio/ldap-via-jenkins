#!/bin/bash
workspace=$(dirname 0)

terraform destroy $workspace

exit $EXIT_STATUS
