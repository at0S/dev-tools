# Must provision 6 DMZ networks with addresses in /27 range
module "vpc-ohio" {
    source = "../"
    providers = {
        aws = aws.us-east-1
    }
}