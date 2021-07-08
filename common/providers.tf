provider "aws" {
  region  = "ap-southeast-2"
  alias   = "ap-southeast-2"
}

provider "aws" {
    alias = "ap-southeast-1"
    region = "ap-southeast-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
