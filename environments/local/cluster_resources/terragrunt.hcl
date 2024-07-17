terraform {
  source = "../../../modules//cluster_resources"
}

inputs = {
  k3s_config_dir = abspath("../.kubeconfig")
}

dependency "compute" {
  config_path = "../compute"
  skip_outputs = true
}