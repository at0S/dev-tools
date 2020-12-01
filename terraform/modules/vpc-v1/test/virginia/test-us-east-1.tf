# Must provision 6 DMZ networks with addresses in /27 range
# Note: by default, Elastic IP limit is 5 and here we're attempting 6 subnets. That must fail.
module "vpc-virginia" {
    source = "../"

    cidr = "192.168.0.0/16"
    environment = "test"
    tenant = "dummy"

    providers = {
        aws = aws.us-east-1
    }
}
