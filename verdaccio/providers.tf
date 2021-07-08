provider "aws" {
  version = "~> 3.0"
  region  = "ap-southeast-2"
  alias   = "ap-southeast-2"
}

provider "kubernetes" {
  version = "1.13.3"
}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config"
  version = "0.2.1"
  server_side_planning = false
}