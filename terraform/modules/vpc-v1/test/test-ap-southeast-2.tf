# Must provision 3 DMZ networks with addresses in /26 range
module "vpc-sydney" {
    source = "../"
    providers = {
        aws = aws.ap-southeast-2
    }
}