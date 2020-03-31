#!/bin/bash

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$ENVIRONMENT_NAME" ]; then
    echo "Must provide environment name ENVIRONMENT_NAME as environment variable"
    echo "Set this to the same value of environment_name var in terraform.tfvars"
    exit 1
fi

export STATE_FILE=${__DIR}/../control-plane/state/"$ENVIRONMENT_NAME"/terraform.tfstate

# shellcheck source=/dev/null
[[ -f "${__DIR}/set-om-creds.sh" ]] &&  \
  source "${__DIR}/set-om-creds.sh" ||  \
  (echo "set-om-creds.sh not found" && exit 1)

VARS_om_target=$OM_TARGET
export VARS_om_target
VARS_om_username=$OM_USERNAME
export VARS_om_username
VARS_om_password=$OM_PASSWORD
export VARS_om_password
VARS_om_decryption_passphrase=$OM_DECRYPTION_PASSPHRASE
export VARS_om_decryption_passphrase

om interpolate --config ./templates/env.yml \
  --vars-env VARS > /tmp/env.yml
eval "$(om --env /tmp/env.yml bosh-env)"

# shellcheck source=/dev/null
[[ -d "${HOME}/.ssh" ]] ||  \
  (echo "Directory '${HOME}/.ssh' not found" && exit 1)


private_key="$HOME"/.ssh/om_control_plane_azure_ssh_key
[[ ! -f ${private_key} ]] && echo "opsman ssh private key written to '${private_key}'"

terraform output -state="${STATE_FILE}" ops_manager_ssh_private_key > "$private_key"

export BOSH_ALL_PROXY="ssh+socks5://ubuntu@${OM_TARGET}:22?private-key=${private_key}"
export CREDHUB_PROXY=$BOSH_ALL_PROXY
