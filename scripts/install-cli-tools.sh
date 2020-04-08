#!/bin/bash

function install_terraform {
  version="${TERRAFORM_VERSION:-0.12.24}"
  os="${OS:-linux}"
  arch="${ARCH:-${arch}}"
  file="terraform.zip"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip
  unzip $file
  chmod +x terraform
  sudo mv terraform /usr/local/bin/terraform
  rm $file
  type terraform
  terraform --version
}

function install_pivnet_cli {
  version="${PIVNET_VERSION:-1.0.2}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"
  file="pivnet"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://github.com/pivotal-cf/pivnet-cli/releases/download/v${version}/pivnet-${os}-${arch}-${version}
  chmod +x $file
  sudo mv $file /usr/local/bin/pivnet
  type pivnet
  pivnet --version
}

function install_jq {
  version="${JQ_VERSION:-1.6}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"
  if [[ "${os}" == "darwin" ]]; then
    os="osx-${arch}"
  fi
  if [[ "${os}" == "linux" ]]; then
    os="${os}64"
  fi
  file="jq"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file "https://github.com/stedolan/jq/releases/download/jq-${version}/jq-${os}"
  chmod +x $file
  sudo mv $file /usr/local/bin/jq
  type jq
  jq --version
}

function install_om {
  version="${OM_VERSION:-4.6.0}"
  os="${OS:-linux}"
  file="om"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://github.com/pivotal-cf/om/releases/download/${version}/om-${os}-${version}
  chmod +x $file
  sudo mv $file /usr/local/bin/om
  type om
  om version
}

function install_credhub {
  version="${CREDHUB_VERSION:-2.7.0}"
  os="${OS:-linux}"
  file="credhub.tgz"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${version}/credhub-${os}-${version}.tgz
  tar -xvf $file
  rm $file
  chmod +x credhub
  sudo mv credhub /usr/local/bin/credhub
  type credhub
  credhub --version
}

function install_k8s_clis {
  version="${PKS_VERSION:-1.7.0}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"

  pivnet login --api-token "$PIVNET_TOKEN"

  pivnet download-product-files -p pivotal-container-service -r ${version} -g "pks-${os}-${arch}*"
  pivnet download-product-files -p pivotal-container-service -r ${version} -g "kubectl-${os}-${arch}*"

  chmod +x pks*
  sudo mv pks-$os-* /usr/local/bin/pks
  type pks
  pks --version
  chmod +x kubectl-$os-*
  sudo mv kubectl* /usr/local/bin/kubectl
  type kubectl
  kubectl version --client
}

function install_helm_cli {
  version="${HELM_CLI_VERSION:-v3.1.2}"
  os="${OS:-linux}"
  arch="${ARCH:-${arch}}"
  file="helm.tar.gz"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://get.helm.sh/helm-${version}-${os}-${arch}.tar.gz
  tar -zxvf $file --strip=1 -C /tmp
  chmod +x /tmp/helm
  sudo mv /tmp/helm /usr/local/bin/helm
  rm $file
  type helm
  helm version
}

function install_bosh_cli {
  version="${BOSH_VERSION:-6.2.1}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"
  file="bosh"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://github.com/cloudfoundry/bosh-cli/releases/download/v${version}/bosh-cli-${version}-${os}-${arch}
  chmod +x $file
  sudo mv $file /usr/local/bin/bosh
  type bosh
  bosh --version
}

function install_minio_client {
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"
  file="mc"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://dl.minio.io/client/mc/release/${os}-${arch}/mc
  chmod +x $file
  sudo mv $file /usr/local/bin/mc
  type mc
  mc --version
}

function install_kpack_logs {
  version="${KPACK_VERSION:-v0.0.8}"
  os="${OS:-linux}"
  if [[ $os == darwin ]]; then
    os="macos"
  fi
  file="logs.tgz"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://github.com/pivotal/kpack/releases/download/${version}/logs-${version}-${os}.tgz
  tar -xvf $file
  rm $file
  chmod +x logs
  sudo mv logs /usr/local/bin/logs
  type logs
}

function install_ytt {
  version="${YTT_VERSION:-0.26.0}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"

  pivnet login --api-token "$PIVNET_TOKEN"

  pivnet download-product-files --product-slug='ytt' --release-version="$version" --glob=ytt-${os}-${arch}*

  chmod +x ytt*
  sudo mv ytt-$os-* /usr/local/bin/ytt
  type ytt
  ytt version
}

function install_kapp {
  version="${KAPP_VERSION:-0.22.0}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"

  pivnet login --api-token "$PIVNET_TOKEN"

  pivnet download-product-files --product-slug='kapp' --release-version="$version" --glob=kapp-${os}-${arch}*

  chmod +x kapp*
  sudo mv kapp-$os-* /usr/local/bin/kapp
  type kapp
  kapp version
}

function install_kbld {
  version="${KBLD_VERSION:-v0.19.0}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"
  file="kbld"
  trap "{ rm -f "$file" ; exit 255; }" EXIT
  wget -O $file https://github.com/k14s/${file}/releases/download/${version}/${file}-${os}-${arch}
  chmod +x $file
  sudo mv $file /usr/local/bin/$file
  type $file
  $file version
}

set -eou pipefail

echo "Enter your Operating System (linux, darwin, windows): "
read -r OS

echo "Enter your OS Architecture (amd64, 386): "
read -r ARCH

if [ -z "$PIVNET_TOKEN" ]; then
  echo "Enter your Pivnet refresh token: "
  read -rs PIVNET_TOKEN
fi

if [[ $OS == linux ]]; then
  sudo apt install zip -y
fi

install_terraform
install_pivnet_cli
install_jq
install_om
install_credhub
install_k8s_clis
install_helm_cli
install_bosh_cli
install_minio_client
install_kpack_logs
install_ytt
install_kapp
install_kbld
