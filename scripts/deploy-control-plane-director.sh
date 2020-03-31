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

director_bosh_root_storage_account="$(terraform output -state="${STATE_FILE}" bosh_root_storage_account)"
export director_bosh_root_storage_account
director_client_id="$(terraform output -state="${STATE_FILE}" client_id)"
export director_client_id
director_client_secret="$(terraform output -state="${STATE_FILE}" client_secret)"
export director_client_secret
director_default_security_group_name="$(terraform output -state="${STATE_FILE}" plane_security_group_name)"
export director_default_security_group_name
director_resource_group_name="$(terraform output -state="${STATE_FILE}" resource_group_name)"
export director_resource_group_name
director_ops_manager_ssh_public_key="$(terraform output -state="${STATE_FILE}" ops_manager_ssh_public_key)"
export director_ops_manager_ssh_public_key
director_ops_manager_ssh_private_key="$(terraform output -state="${STATE_FILE}" ops_manager_ssh_private_key)"
export director_ops_manager_ssh_private_key
director_subscription_id="$(terraform output -state="${STATE_FILE}" subscription_id)"
export director_subscription_id
director_tenant_id="$(terraform output -state="${STATE_FILE}" tenant_id)"
export director_tenant_id
director_network="$(terraform output -state="${STATE_FILE}" network)"
export director_network
director_subnetwork="$(terraform output -state="${STATE_FILE}" subnetwork)"
export director_subnetwork
director_internal_cidr="$(terraform output -state="${STATE_FILE}" internal_cidr)"
export director_internal_cidr
director_reserved_ip_ranges="$(terraform output -state="${STATE_FILE}" reserved_ip_ranges)"
export director_reserved_ip_ranges
director_internal_gw="$(terraform output -state="${STATE_FILE}" internal_gw)"
export director_internal_gw
director_dns_servers="$(terraform output -state="${STATE_FILE}" dns_servers)"
export director_dns_servers

# shellcheck source=/dev/null
[[ -f "${__DIR}/set-om-creds.sh" ]] &&  \
  source "${__DIR}/set-om-creds.sh" ||  \
  (echo "set-om-creds.sh not found" && exit 1)

echo "Configuring Ops Manager Authentication"
om -t "$OM_TARGET" --skip-ssl-validation \
  configure-authentication \
    --decryption-passphrase "$OM_DECRYPTION_PASSPHRASE" \
    --username "$OM_USERNAME" \
    --password "$OM_PASSWORD"

echo "Configuring Ops Manager Director"
om -t "$OM_TARGET" --skip-ssl-validation \
  configure-director --config "${__DIR}/../templates/director.yml" --vars-env=director

echo "Deploying Ops Manager Director"
om -t "$OM_TARGET" --skip-ssl-validation apply-changes
