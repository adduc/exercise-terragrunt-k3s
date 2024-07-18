## Required Providers

terraform {
  required_providers {
    helm = {
      # @see https://registry.terraform.io/providers/hashicorp/helm/latest/docs
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
    kubernetes = {
      # @see https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

## Variables

variable "k3s_config_dir" { default = "../config" }

## Providers

provider "kubernetes" {
  config_path = "${var.k3s_config_dir}/kubeconfig.yaml"
}

provider "helm" {
  kubernetes {
    config_path = "${var.k3s_config_dir}/kubeconfig.yaml"
  }
}

## Gateway API CRDs

# @see https://gateway-api.sigs.k8s.io/
# @see https://artifacthub.io/packages/helm/portefaix-hub/gateway-api-crds
resource "helm_release" "gateway_api" {
  name       = "my-gateway-api-crds"
  repository = "https://charts.portefaix.xyz/"
  chart      = "gateway-api-crds"
  version    = "1.1.0"
}
