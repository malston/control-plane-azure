# Deploy Ops Manager Control Plane onto Azure

This repo contains scripts and terraform configurations to deploy a control
plane, opsmanager and PKS to Azure Cloud.

### Setup Variables

```sh
cat > .envrc <<EOF
export AZURE_CLIENT_ID=<application client id>
export AZURE_CLIENT_SECRET=<application client secret>
export AZURE_REGION=<azure region>
export AZURE_TENANT_ID=<azure tenant it>
export AZURE_SUBSCRIPTION_ID=<azure subscription id>
export AZURE_STORAGE_ACCOUNT_KEY=<azure storage account key>
export ENVIRONMENT_NAME=controlplane
EOF
```

Run the following source command to set the environment variables into your shell or install [direnv](https://direnv.net/) to do this automatically.

```sh
source .envrc
```

### Control Plane

- Run `./scripts/install-cli-tools.sh` to install required CLI tools
- Update `./versions.yml` to use latest versions
- Follow [these instructions](https://docs.pivotal.io/platform/ops-manager/2-8/azure/prepare-azure-terraform.html#install) to create and configure the Service Principal account that is needed to run the terraform templates. To save time, you can run `./scripts/create-service-account.sh`
- Copy `./control-plane/vars/$ENVIRONMENT_NAME/terraform.tfvars.example` to `./control-plane/vars/$ENVIRONMENT_NAME/terraform.tfvars` and modify with your configuration choices and credentials.
- Run `./scripts/terraform-control-plane-apply.sh` - this will create the
  infrastructure required in Azure for a control-plane.
- Update `opsman.yml` and `director.yml` in the control-plane vars directory.
- Run `./scripts/download-opsman.yml`
- Run `./scripts/deploy-opsman.yml`
- Verify that the opsmanager is online and accessible.
- Run `./scripts/download-control-plane.sh` to download releases control plane from pivnet
- Finally run `./scripts/deploy-control-plane.sh` to deploy the control plane.