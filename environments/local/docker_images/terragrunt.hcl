terraform {
  source = "../../../modules//docker_images"
}

inputs = {
  env_name = "local"
  k3s_config_dir = abspath("../.kubeconfig")
}