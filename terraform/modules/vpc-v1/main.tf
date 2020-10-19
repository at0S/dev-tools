# IPv4 cidr blocks for AWS VPC are between
# /16 (65536 addresses) netmask and /28 (16 addresses)

resource "random_string" "this" {
    length = 12
    special = false
}

data "aws_availability_zones" "this" {
    state = "available"
}

locals  {
    suffix = var.suffix != "" ? var.suffix : random_string.this.result
    zones = length(data.aws_availability_zones.this.names)
    cidr_block = split("/", var.cidr)[0]
    cidr_mask = split("/", var.cidr)[1]
    dmz_cidr_subnets = length(data.aws_availability_zones.this.names) <= 4 ? cidrsubnets(cidrsubnet(var.cidr, 8, 254), 2,2,2,2) : cidrsubnets(cidrsubnet(var.cidr, 8, 254), 3,3,3,3,3,3,3,3)
}

# VPC with default settings and passed-in CIDR block
resource "aws_vpc" "this" {
    cidr_block = var.cidr
    tags = {
        "Name" = "${var.tenant}-vpc-${var.environment}-${local.suffix}"
    }
}

# Provision a DMZ subnet in every availability zone
# DMZ network is always in w.x.y.z/26 range, so we can q
# use a single w.x.y.z/24 network withing VPC for DMZ.
# Unless there is more than 4 zones, then the networks
# would fall into the w.x.y.z/27 range
resource "aws_subnet" "dmz" {
    count = local.zones
    vpc_id = aws_vpc.this.id
    availability_zone = data.aws_availability_zones.this.names[count.index]
    cidr_block = local.dmz_cidr_subnets[count.index]
    tags = merge(
        {
            Name = "${var.tenant}-subnet-dmz-${var.environment}-${count.index + 1}"
        },
        var.subnet_tags,
    )
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


# Routing table for DMZ networks
# 0.0.0.0 via InternetGateway
resource "aws_route_table" "dmz" {
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${var.tenant}-rtb-dmz-${var.environment}"
    }
}

resource "aws_route" "default" {
    route_table_id = aws_route_table.dmz.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
}  

# All DMZ networks have their own associations with the dmz route table
resource "aws_route_table_association" "dmz" {
    count = local.zones
    subnet_id = aws_subnet.dmz[count.index].id
    route_table_id = aws_route_table.dmz.id
}