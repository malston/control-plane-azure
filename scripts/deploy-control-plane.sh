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

export STATE_FILE=${__DIR}/../control-plane/state/"$ENVIRONMENT_NAME"/terraform.tfstate

cp_plane_lb_name=$(terraform output -state="${STATE_FILE}" plane_lb_name)
export cp_plane_lb_name
cp_uaa_lb_name=$(terraform output -state="${STATE_FILE}" uaa_lb_name)
export cp_uaa_lb_name
cp_credhub_lb_name=$(terraform output -state="${STATE_FILE}" credhub_lb_name)
export cp_credhub_lb_name
cp_plane_dns_name=$(terraform output -state="${STATE_FILE}" plane_dns)
export cp_plane_dns_name
cp_uaa_dns_name=$(terraform output -state="${STATE_FILE}" uaa_dns)
export cp_uaa_dns_name
cp_credhub_dns_name=$(terraform output -state="${STATE_FILE}" credhub_dns)
export cp_credhub_dns_name

# shellcheck source=/dev/null
[[ -f "${__DIR}/set-om-creds.sh" ]] &&  \
  source "${__DIR}/set-om-creds.sh" ||  \
  (echo "set-om-creds.sh not found" && exit 1)

cp_ca_cert=$(om -t "$OM_TARGET" --skip-ssl-validation certificate-authorities \
  --format json | jq -r '.[0] | select(.active==true) | .cert_pem' )
export cp_ca_cert

om -t "$OM_TARGET" --skip-ssl-validation generate-certificate \
  -d "${cp_uaa_dns_name},${cp_credhub_dns_name},${cp_plane_dns_name}" > /tmp/om_generated_cert.json

cp_control_plane_tls_cert=$(jq -r .certificate /tmp/om_generated_cert.json)
export cp_control_plane_tls_cert
cp_control_plane_tls_private_key=$(jq -r .key /tmp/om_generated_cert.json)
export cp_control_plane_tls_private_key

# Configure control plane product
om -t "$OM_TARGET" --skip-ssl-validation \
 configure-product --config "${__DIR}/../templates/control-plane.yml" --vars-env=cp

# Deploy control plane
om -t "$OM_TARGET" --skip-ssl-validation apply-changes
