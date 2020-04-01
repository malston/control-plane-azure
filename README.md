# Deploy Ops Manager Control Plane onto Azure

This repo contains scripts and terraform configurations to deploy a control
plane, opsmanager and PKS to Azure Cloud.

## Setup Variables

```sh
cat > .envrc <<EOF
export AZURE_CLIENT_ID=<application client id>
export AZURE_CLIENT_SECRET=<application client secret>
export AZURE_REGION=<azure region>
export AZURE_TENANT_ID=<azure tenant it>
export AZURE_SUBSCRIPTION_ID=<azure subscription id>
export ENVIRONMENT_NAME=controlplane
EOF
```

Run the following source command to set the environment variables into your shell or install [direnv](https://direnv.net/) to do this automatically.

```sh
source .envrc
```

## DNS

- Create a [DNS zone](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns#create-a-dns-zone) in Azure Portal

- Perform a DNS query to make sure the correct nameservers are resolved

  ```sh
  nslookup -type=SOA foo.example.com
  ```

## Control Plane

### Install Tools

- Run `./scripts/install-cli-tools.sh` to install required CLI tools

### Update Versions

- Update `./versions.yml` to use latest versions

### Create Azure Active Directory Service Account

- Follow [these instructions](https://docs.pivotal.io/platform/ops-manager/2-8/azure/prepare-azure-terraform.html#install) to create and configure the Service Principal account that is needed to run the terraform templates. To save time, you can run `./scripts/create-service-account.sh`

### Terraforming

- Copy `./control-plane/vars/$ENVIRONMENT_NAME/terraform.tfvars.example` to `./control-plane/vars/$ENVIRONMENT_NAME/terraform.tfvars` and modify with your configuration choices and credentials.
- Run `./scripts/terraform-control-plane-apply.sh` - this will create the
  infrastructure required in Azure for a control-plane.

### Configure Operations Manager and Deploy Director

- Configure opsman auth and the director tile

```sh
./scripts/deploy-control-plane-director.sh
```

### Deploy Control Plane Product

- Download the product and stemcell from pivnet. Ensure environment variable `$PIVNET_TOKEN` is set.

```sh
./scripts/download-control-plane.sh
```

The version is set in `./versions.yml`:

```yaml
control_plane_version: 0.0.37
```

- Upload and Stage the product and upload/assign the stemcell.

```sh
./scripts/stage-control-plane.sh
```

- Create VM Extensions for load balancers and Security Groups.

```sh
./scripts/create-vm-extensions.sh
```

- Apply control-plane configuration and deploy.

```sh
./scripts/deploy-control-plane.sh
```

### Access BOSH

```sh
source ./scripts/target-control-plane-bosh.sh
```

### Access Credhub

```sh
source ./target-concourse-credhub.sh
```

### Access Concourse

```sh
./scripts/login-concourse.sh
```
