terraform {
  source = "../../../modules//compute"
}

inputs = {
  k3s_config_dir = abspath("../.kubeconfig")
}