terraform {
  source = "../../../modules//cluster_resources"
}

inputs = {
  k3s_config_dir = abspath("${get_original_terragrunt_dir()}/../.kubeconfig")
}

dependency "cluster_crds" {
  config_path = "../cluster_crds"
  skip_outputs = true
}