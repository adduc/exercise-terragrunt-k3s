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

## Resources

# Gateway API CRDs
# @see https://gateway-api.sigs.k8s.io/
# @see https://artifacthub.io/packages/helm/portefaix-hub/gateway-api-crds
resource "helm_release" "gateway_api" {
  name       = "my-gateway-api-crds"
  repository = "https://charts.portefaix.xyz/"
  chart      = "gateway-api-crds"
  version    = "1.1.0"
}

resource "kubernetes_namespace" "nginx-gateway" {
  metadata {
    name = "nginx-gateway"
  }
}

# Nginx Gateway Fabric (Gateway API implementation)
# helm install ngf oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway
resource "helm_release" "nginx_gateway_fabric" {
  depends_on = [kubernetes_namespace.nginx-gateway]
  name       = "nginx-gateway-fabric"
  repository = "oci://ghcr.io/nginxinc/charts"
  chart      = "nginx-gateway-fabric"
  version    = "1.3.0"
  namespace  = kubernetes_namespace.nginx-gateway.metadata.0.name
}