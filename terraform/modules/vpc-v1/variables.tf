variable "vpc_cidr" {
    description = "CIDR block for VPC. Must be within /16 - /28"
    type = string
    default = "192.168.0.0/16"
}