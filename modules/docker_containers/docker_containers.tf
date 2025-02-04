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

variable "env_name" { type = string }

variable "k3s_version" { default = "v1.29.6-k3s1" }
variable "k3s_token" { default = "changeme" }
variable "k3s_config_dir" { default = "../config" }

## Providers

provider "docker" {}

## Resources

resource "docker_image" "k3s" {
  name = "rancher/k3s:${var.k3s_version}"
}

resource "docker_container" "k3s" {
  name         = "${var.env_name}_k3s"
  image        = docker_image.k3s.image_id
  restart      = "unless-stopped"
  stop_signal  = "SIGKILL"
  privileged   = true
  network_mode = "bridge"

  # wait for the cluster to be ready before considering the resource as
  # created to allow subsequent terragrunt modules to interact with the
  # cluster immediately
  wait = true

  command = [
    "server",
    "--disable", "traefik",
    "--disable", "servicelb",
    "--disable", "metrics-server",
  ]

  tmpfs = {
    "/run"     = "",
    "/var/run" = "",
  }

  env = [
    "K3S_TOKEN=${var.k3s_token}",
    "K3S_KUBECONFIG_OUTPUT=/output/kubeconfig.yaml",
    "K3S_KUBECONFIG_MODE=666",
  ]

  ports {
    internal = 6443
    external = 6443
  }

  ports {
    internal = 30080
    external = 30080
  }

  volumes {
    host_path      = abspath(var.k3s_config_dir)
    container_path = "/output"
  }

  ulimit {
    name = "nproc"
    soft = 65535
    hard = 65535
  }

  healthcheck {
    test     = ["CMD-SHELL", "kubectl get nodes"]
    interval = "1s"
    timeout  = "1s"
    retries  = 15
  }
}

## Outputs

