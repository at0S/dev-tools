# IPv4 cidr blocks for AWS VPC are between
# /16 (65536 addresses) netmask and /28 (16 addresses)

data "aws_availability_zones" "this" {
    state = "available"
}

locals  {
    zones = length(data.aws_availability_zones.this.names)
    cidr_block = split("/", var.cidr)[0]
    cidr_mask = split("/", var.cidr)[1]
    dmz_cidr_subnets = length(data.aws_availability_zones.this.names) <= 4 ? cidrsubnets(cidrsubnet(var.cidr, 8, 254), 2,2,2,2) : cidrsubnets(cidrsubnet(var.cidr, 8, 254), 3,3,3,3,3,3,3,3)
}

# VPC with default settings and passed-in CIDR block
resource "aws_vpc" "this" {
    cidr_block = var.cidr
    tags = {
        "Name" = "${var.tenant}-vpc-${var.environment}"
    }
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
        Name = "${var.tenant}-subnet-dmz-${var.environment}-${count.index + 1}"
    }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${var.tenant}-igw-${var.environment}"
    }
}

resource "aws_eip" "this" {
    count = local.zones
    vpc = true
    depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
    count = local.zones
    allocation_id = aws_eip.this[count.index].id
    subnet_id = aws_subnet.dmz[count.index].id
    tags = {
        Name = "${var.tenant}-nat-${var.environment}-${count.index + 1}"
    }
}

# We would need routing table per DMZ as we have a NAT gateway in every AZ 
resource "aws_route_table" "dmz" {
    count = local.zones
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${var.tenant}-rtb-dmz-${var.environment}-${count.index + 1}"
    }
}

resource "aws_route_table_association" "dmz" {
    count = local.zones
    subnet_id = aws_subnet.dmz[count.index].id
    route_table_id = aws_route_table.dmz[count.index].id
}

resource "aws_route" "default" {
    count = local.zones
    route_table_id = aws_route_table.dmz[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
}