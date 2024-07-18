terraform {
  source = "../../../modules//cluster_resources"
}

inputs = {
  k3s_config_dir = abspath("../.kubeconfig")
}

dependency "cluster_crds" {
  config_path = "../cluster_crds"
  skip_outputs = true
}