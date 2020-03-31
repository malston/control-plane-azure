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

ext_plane_lb=$(terraform output -state="${STATE_FILE}" plane_lb_name)
export ext_plane_lb
ext_uaa_lb=$(terraform output -state="${STATE_FILE}" uaa_lb_name)
export ext_uaa_lb
ext_credhub_lb=$(terraform output -state="${STATE_FILE}" credhub_lb_name)
export ext_credhub_lb
ext_plane_security_group=$(terraform output -state="${STATE_FILE}" plane_security_group_name)
export ext_plane_security_group
ext_uaa_security_group=$(terraform output -state="${STATE_FILE}" uaa_security_group_name)
export ext_uaa_security_group
ext_credhub_security_group=$(terraform output -state="${STATE_FILE}" credhub_security_group_name)
export ext_credhub_security_group

cat > /tmp/vm-extension-web.yml <<-EOF
---
vm-extension-config:
  name: plane-lb-cloud-properties
  cloud_properties:
    security_group: ((plane_security_group))
    load_balancer: ((plane_lb))
EOF

cat > /tmp/vm-extension-uaa.yml <<-EOF
---
vm-extension-config:
  name: uaa-lb-cloud-properties
  cloud_properties:
    security_group: ((uaa_security_group))
    load_balancer: ((uaa_lb))
EOF

cat > /tmp/vm-extension-credhub.yml <<-EOF
---
vm-extension-config:
  name: credhub-lb-cloud-properties
  cloud_properties:
    security_group: ((credhub_security_group))
    load_balancer: ((credhub_lb))
EOF

# shellcheck source=/dev/null
[[ -f "${__DIR}/set-om-creds.sh" ]] &&  \
  source "${__DIR}/set-om-creds.sh" ||  \
  (echo "set-om-creds.sh not found" && exit 1)

# Create VM extension for Web
om -t "$OM_TARGET" --skip-ssl-validation \
  create-vm-extension --config /tmp/vm-extension-web.yml --vars-env=ext

# Create VM extension for UAA
om -t "$OM_TARGET" --skip-ssl-validation \
  create-vm-extension --config /tmp/vm-extension-uaa.yml --vars-env=ext

# Create VM extension for Credhub
om -t "$OM_TARGET" --skip-ssl-validation \
  create-vm-extension --config /tmp/vm-extension-credhub.yml --vars-env=ext
