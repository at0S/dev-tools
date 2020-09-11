data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "ifm-tools" {
  cidr_block = "10.110.0.0/16"
  tags = {
    Name          = "ifm-tools-apse2"
    Owner         = "tyermolenko"
    ProvisionedBy = "terrafrom"
  }
}