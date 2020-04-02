#!/bin/bash

set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$ENVIRONMENT_NAME" ]; then
    echo "Must provide environment name ENVIRONMENT_NAME as environment variable"
    echo "Set this to the same value of environment_name var in terraform.tfvars"
    exit 1
fi

terraform_dir="${__DIR}/../control-plane/terraform"

state_dir="${__DIR}/../control-plane/state/$ENVIRONMENT_NAME"
vars_dir="${__DIR}/../control-plane/vars/$ENVIRONMENT_NAME"

mkdir -p "${state_dir}"
mkdir -p "${vars_dir}"

pushd "${terraform_dir}" > /dev/null
  terraform init
  terraform plan -var-file="${vars_dir}/terraform.tfvars" \
    -out="${state_dir}/terraform.tfplan"
  terraform apply \
    -state="${state_dir}/terraform.tfstate" \
    "${state_dir}/terraform.tfplan"
popd > /dev/null

terraform output -state="${state_dir}/terraform.tfstate"
