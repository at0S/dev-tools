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

variable "subnet_tags" {
    description = "Additional tags for a subnet"
    default = {}
}

variable "suffix" {
    description = "random sequence, if empty(default) will generate its own value"
    default = ""
}