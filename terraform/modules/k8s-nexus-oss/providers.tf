provider "kubernetes" {
  version = "1.13.3"
}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config"
  version = "0.2.1"
  server_side_planning = false
}