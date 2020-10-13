variable "tenant" {
    description = "Used to identify who the resources belongs to, mainly in name tags"
    type = string
}

variable "environment" {
    description = "which environment resource belongs too, like 'development', 'production', etc"
}

variable "cidr" {
    description = "CIDR block for VPC. Must be within 16 - 28 bit mask"
    type = string
}