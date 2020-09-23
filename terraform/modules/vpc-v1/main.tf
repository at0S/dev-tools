# IPv4 cidr blocks for AWS VPC are between
# /16 (65536 addresses) netmask and /28 (16 addresses)

data "aws_availability_zones" "this" {
    state = "available"
}

locals  {
    zones = length(data.aws_availability_zones.this.names)
    cidr_block = split("/", var.vpc_cidr)[0]
    cidr_mask = split("/", var.vpc_cidr)[1]
    dmz_cidr_subnets = length(data.aws_availability_zones.this.names) <= 4 ? cidrsubnets(cidrsubnet(var.vpc_cidr, 8, 254), 2,2,2,2) : cidrsubnets(cidrsubnet(var.vpc_cidr, 8, 254), 3,3,3,3,3,3,3,3)
}

# VPC with default settings and passed-in CIDR block
resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
}

# Provision a DMZ subnet in every availability zone
# DMZ network is always in w.x.y.z/26 range, so we can 
# use a single w.x.y.z/24 network withing VPC for DMZ.
# Unless there is more than 4 zones, then the networks
# would fall into the w.x.y.z/27 range
resource "aws_subnet" "dmz" {
    count = local.zones
    vpc_id = aws_vpc.this.id
    availability_zone = data.aws_availability_zones.this.names[count.index]
    cidr_block = local.dmz_cidr_subnets[count.index]
    tags = {
        Name = "DMZ-Network-${count.index + 1}"
    }
}