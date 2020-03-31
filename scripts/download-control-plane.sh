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

if [ -z "$PIVNET_TOKEN" ]; then
    echo "Must provide pivnet api token as environment variable PIVNET_TOKEN"
    exit 1
fi

version=$(om interpolate --config "${__DIR}/../versions.yml" --path /control_plane_version)
files_directory="${__DIR}/../control-plane/files/$ENVIRONMENT_NAME"

mkdir -p "${files_directory}"

# Download control plane product and stemcell
om --skip-ssl-validation download-product \
       --output-directory "${files_directory}" \
       --pivnet-file-glob "control-plane*.pivotal" \
       --pivnet-api-token "$PIVNET_TOKEN" \
       --pivnet-product-slug "p-control-plane-components" \
       --stemcell-iaas "azure" \
       --product-version-regex "$version"
       