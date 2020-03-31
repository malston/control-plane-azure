#!/bin/bash

# set -e
# # only exit with zero if all commands of the pipeline exit successfully
# set -o pipefail

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$ENVIRONMENT_NAME" ]; then
    echo "Must provide environment name ENVIRONMENT_NAME as environment variable"
    echo "Set this to the same value of environment_name var in terraform.tfvars"
    exit 1
fi

export STATE_FILE=${__DIR}/../control-plane/state/"$ENVIRONMENT_NAME"/terraform.tfstate

# shellcheck source=/dev/null
[[ -f "${__DIR}/target-control-plane-bosh.sh" ]] &&  \
 source "${__DIR}/target-control-plane-bosh.sh" ||  \
 (echo "target-control-plane-bosh.sh not found" || exit 1)


export CREDHUB_CLIENT=$BOSH_CLIENT
export CREDHUB_SECRET=$BOSH_CLIENT_SECRET
export CREDHUB_CA_CERT=$BOSH_CA_CERT
export CREDHUB_SERVER="https://$BOSH_ENVIRONMENT:8844"

# login to the BOSH director Credhub using info from bbl
echo "Connecting to Credhub on BOSH Director...."
credhub login

CONCOURSE_CREDHUB_CLIENT=$(om --env /tmp/env.yml credentials \
  --product-name control-plane \
  --credential-reference .uaa.credhub_admin_client_credentials \
  --credential-field identity)

CONCOURSE_CREDHUB_SECRET=$(om --env /tmp/env.yml credentials \
  --product-name control-plane \
  --credential-reference .uaa.credhub_admin_client_credentials \
  --credential-field password)

# Read the CA certificate and client secret from the BOSH director's Credhub
CONCOURSE_CREDHUB_CA_CERT=$(om --env /tmp/env.yml certificate-authorities --format json \
  | jq -r '.[0].cert_pem')

credhub_dns_name=$(terraform output -state="${STATE_FILE}" credhub_dns)

# Reset credhub environment variables to point at the concourse credhub
export CREDHUB_SERVER="https://${credhub_dns_name}:8844"
export CREDHUB_CLIENT=${CONCOURSE_CREDHUB_CLIENT}
export CREDHUB_SECRET=${CONCOURSE_CREDHUB_SECRET}
export CREDHUB_CA_CERT=${CONCOURSE_CREDHUB_CA_CERT}

echo "Connecting to Concourse Credhub..."

credhub login
