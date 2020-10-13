module "vpc-ifm-tools-sydney" {
  source = "../terraform/modules/vpc-v1"

  cidr        = "10.200.0.0/16"
  environment = "production"
  tenant      = "ifm"

  providers = {
    aws = aws.ap-southeast-2
  }
}

module "vpc-ifm-tools-singapore" {
  source = "../terraform/modules/vpc-v1"

  cidr        = "10.100.0.0/16"
  environment = "production"
  tenant      = "ifm"

  providers = {
    aws = aws.ap-southeast-1
  }
}