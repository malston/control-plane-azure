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

version=$(om interpolate --config "${__DIR}/../versions.yml" --path /control_plane_version)
files_directory="${__DIR}/../control-plane/files/$ENVIRONMENT_NAME"

mkdir -p "${files_directory}"

export STATE_FILE=${__DIR}/../control-plane/state/"$ENVIRONMENT_NAME"/terraform.tfstate

# shellcheck source=/dev/null
[[ -f "${__DIR}/set-om-creds.sh" ]] &&  \
  source "${__DIR}/set-om-creds.sh" ||  \
  (echo "set-om-creds.sh not found" && exit 1)

# Upload control plane product
om -t "$OM_TARGET" --skip-ssl-validation upload-product \
       --product "${files_directory}"/*.pivotal \

version=$(om -t "$OM_TARGET" --skip-ssl-validation available-products --format json | \
       jq -r '.[] | select(.name=="control-plane") | .version')

# Stage control plane
om -t "$OM_TARGET" --skip-ssl-validation stage-product \
       --product-name "control-plane" \
       --product-version "${version}"

# Upload stemcell
om -t "$OM_TARGET" --skip-ssl-validation upload-stemcell \
       --floating="true" \
       --stemcell "${files_directory}"/*.tgz

# Assign stemcell
om -t "$OM_TARGET" --skip-ssl-validation assign-stemcell \
        --product "control-plane" \
        --stemcell "$(jq -r .stemcell "${files_directory}"/assign-stemcell.yml)"
