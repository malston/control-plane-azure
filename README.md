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
EOF
```

Run the following source command to set the environment variables into your shell or install [direnv](https://direnv.net/) to do this automatically.

```
source .envrc
```

### Control Plane

- Run `./scripts/init.sh` to install required tools
- Update `./versions.yml` to use latest versions
- Update `./control-plane/vars/$ENVIRONMENT_NAME/terraform.tfvars`
- run `./scripts/terraform-control-plane-apply.sh` - this will create the
  infrastructure required in Azure for a control-plane.
- Update `opsman.yml` and `director.yml` in the control-plane vars directory.
- Run `./scripts/download-opsman.yml`
- Run `./scripts/deploy-opsman.yml`
- Verify that the opsmanager is online and accessible.
- Run `./scripts/download-control-plane.sh` to download releases control plane from pivnet
- Finally run `./scripts/deploy-control-plane.sh` to deploy the control plane.