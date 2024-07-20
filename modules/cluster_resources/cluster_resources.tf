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

## ArgoCD

resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

## Argo CD

# @see https://argoproj.github.io/cd/
# @see https://github.com/argoproj/argo-helm/tree/main
resource "helm_release" "argo" {
  depends_on = [kubernetes_namespace.argo]
  name       = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.3.8"
  namespace  = kubernetes_namespace.argo.metadata.0.name
}

## Nginx Gateway Fabric (Gateway API implementation)

resource "kubernetes_namespace" "nginx-gateway" {
  metadata {
    name = "nginx-gateway"
  }
}

# @see https://github.com/nginxinc/nginx-gateway-fabric
resource "helm_release" "nginx_gateway_fabric" {
  depends_on = [kubernetes_namespace.nginx-gateway]
  name       = "nginx-gateway-fabric"
  repository = "oci://ghcr.io/nginxinc/charts"
  chart      = "nginx-gateway-fabric"
  version    = "1.3.0"
  namespace  = kubernetes_namespace.nginx-gateway.metadata.0.name

  values = [
    yamlencode({
      service = {
        type = "NodePort"
        ports = [{
          port       = 30080
          targetPort = 30080
          nodePort   = 30080
        }]
      }
    })
  ]
}

## Cluster Gateway

resource "kubernetes_namespace" "cluster" {
  metadata {
    name = "cluster"
  }
}

resource "kubernetes_manifest" "gateway" {
  depends_on = [helm_release.nginx_gateway_fabric, kubernetes_namespace.cluster]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    metadata = {
      name      = "gateway"
      namespace = kubernetes_namespace.cluster.metadata[0].name
    }

    spec = {
      gatewayClassName = "nginx"

      listeners = [{
        name     = "http"
        port     = 30080
        protocol = "HTTP"
        allowedRoutes = {
          namespaces = {
            from = "All"
          }
        }
      }]
    }
  }
}
