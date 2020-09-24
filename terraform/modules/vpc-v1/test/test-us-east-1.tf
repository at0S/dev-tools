# Must provision 6 DMZ networks with addresses in /27 range
module "vpc-ohio" {
    source = "../"

    cidr = "192.168.0.0/16"
    environment = "test"
    tenant = "dummy"

    providers = {
        aws = aws.us-east-1
    }
}