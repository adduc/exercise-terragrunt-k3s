## Required Providers

terraform {
  required_providers {
    # @see https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

## Variables

variable "k3s_version" { default = "v1.29.6-k3s1" }

## Providers

provider "docker" {}

## Resources

resource "docker_image" "k3s" {
  name = "rancher/k3s:${var.k3s_version}"
}

## Outputs

output "k3s_image_id" { value = docker_image.k3s.image_id }