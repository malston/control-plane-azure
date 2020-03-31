#!/bin/bash

set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
[[ -f "${__DIR}/target-control-plane-bosh.sh" ]] &&  \
	source "${__DIR}/target-control-plane-bosh.sh" ||  \
	(echo "target-control-plane-bosh.sh not found" || exit 1)

credhub login

CONCOURSE_PASSWORD=$(om --env /tmp/env.yml credentials \
  --product-name control-plane \
  --credential-reference .uaa.uaa_users_admin_credentials \
  --credential-field password)
CONCOURSE_URL="https://$(terraform output -state="${STATE_FILE}" plane_dns)"

printf "\nConcourse url: %s" "${CONCOURSE_URL}"
printf "\nConcourse admin password: %s\n\n" "${CONCOURSE_PASSWORD}"

fly -t main login -c "$CONCOURSE_URL" -u admin -k
