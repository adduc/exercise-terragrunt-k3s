terraform {
  source = "../../../modules//compute"
}

inputs = {
  env_name = "local"
  k3s_config_dir = abspath("../.kubeconfig")
}