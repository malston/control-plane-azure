#!/bin/bash

## Automates the creation of the service account necessary for terraforming
## See https://docs.pivotal.io/platform/ops-manager/2-8/azure/prepare-azure-terraform.html#install

set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail


PASSWORD=$(openssl rand -base64 32)
SUBSCRIPTION_ID="$1"
TENANT_ID=$2
UNIQUE_ID_URI=${3}
DISPLAY_NAME=${4:-"Service Principal for BOSH"}

if [[ -z "$SUBSCRIPTION_ID" ]]; then
	echo "Enter subscription id:"
	read -r SUBSCRIPTION_ID
fi

if [[ -z "$TENANT_ID" ]]; then
	echo "Enter tenant id:"
	read -r TENANT_ID
fi

if [[ -z "$UNIQUE_ID_URI" ]]; then
	echo "Enter identifier uri"
	read -r UNIQUE_ID_URI
fi

echo "Creating app ${DISPLAY_NAME}"
APP_ID=$(az ad app create --display-name "$DISPLAY_NAME" \
  --password "$PASSWORD" --homepage "$UNIQUE_ID_URI" \
  --identifier-uris "$UNIQUE_ID_URI" | jq -r .appId)

ASSIGNEE_ID=$(az ad sp create --id "$APP_ID" | jq -r .objectId)

# eventual consistency... retry until it works
until az role assignment create --assignee "$ASSIGNEE_ID" \
  --role "Owner" --scope /subscriptions/"$SUBSCRIPTION_ID" > /dev/null 2>&1;
do
	echo 'Retrying role assignment...'
	sleep 1
done

echo "Verifying role assignment to ${ASSIGNEE_ID}..."
az role assignment list --assignee "$ASSIGNEE_ID"

echo "Logging in as ${APP_ID}..."
az login --service-principal --username "$APP_ID" --password "$PASSWORD" \
  --tenant "$TENANT_ID" > /dev/null 2>&1;

echo "To register your subscription with Microsoft.Storage, run:"
echo
echo "az provider register --namespace Microsoft.Storage"
echo
echo
echo "To register your subscription with Microsoft.Network, run:"
echo
echo "az provider register --namespace Microsoft.Network"
echo
echo
echo "To register your subscription with Microsoft.Compute, run:"
echo
echo "az provider register --namespace Microsoft.Compute"
echo

echo
echo "Done!"
echo
echo "subscription id: ${SUBSCRIPTION_ID}"
echo "tenant id: ${TENANT_ID}"
echo "client id: ${APP_ID}"
echo "client secret: ${PASSWORD}"
echo "assignee: ${ASSIGNEE_ID}"
echo
