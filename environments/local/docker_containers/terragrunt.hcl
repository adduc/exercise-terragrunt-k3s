terraform {
  source = "../../../modules//docker_containers"
}

inputs = {
  env_name = "local"
  k3s_config_dir = abspath("../.kubeconfig")
}

dependency "docker_images" {
  config_path = "../docker_images"
  skip_outputs = true
}