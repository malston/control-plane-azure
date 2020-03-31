#!/bin/bash

set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

if [ -z "$ENVIRONMENT_NAME" ]; then
    echo "Must provide environment name ENVIRONMENT_NAME as environment variable"
    echo "Set this to the same value of environment_name var in terraform.tfvars"
    exit 1
fi

mkdir -p "./control-plane/state/${ENVIRONMENT_NAME}"

terraform_dir=./control-plane/terraform

pushd ${terraform_dir} > /dev/null
  terraform destroy -var-file=../vars/${ENVIRONMENT_NAME}/terraform.tfvars \
    -state=../state/${ENVIRONMENT_NAME}/terraform.tfstate
popd > /dev/null
