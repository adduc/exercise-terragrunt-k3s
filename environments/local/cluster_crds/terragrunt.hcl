terraform {
  source = "../../../modules//cluster_crds"
}

inputs = {
  k3s_config_dir = abspath("../.kubeconfig")
}

dependency "docker_containers" {
  config_path = "../docker_containers"
  skip_outputs = true
}