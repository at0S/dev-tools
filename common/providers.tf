provider "aws" {
  version = "~> 3.0"
  region  = "ap-southeast-2"
  alias   = "ap-southeast-2"
}

provider "aws" {
    version = "~> 3.0"
    alias = "ap-southeast-1"
    region = "ap-southeast-1"
}