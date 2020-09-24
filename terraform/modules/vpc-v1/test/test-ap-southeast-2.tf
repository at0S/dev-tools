# Must provision 3 DMZ networks with addresses in /26 range
module "vpc-sydney" {
    source = "../"

    cidr = "192.168.0.0/16"
    environment = "test"
    tenant = "dummy"

    providers = {
        aws = aws.ap-southeast-2
    }
}