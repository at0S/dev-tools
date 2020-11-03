variable "application" {
    description = "Name of your application, required."
    type = string
    default = "nexus"
}

variable "environment" {
    description = "Environment, where application runs, used in manifest labels and AWS tags, required."
    type = string
    default = "Production"
}

variable "ver" {
    description = "Version of the service, used in manifest labels and AWS tags, required."
    type = string
}

variable "nexus-fs" {
    description = "Id of the EFS resource, eg fs-01234567, optional."
    type = string
    default = ""
}

variable "nexus-ap" {
    description = "Id of the EFS access point, eg fsa-0123456789abcdeff"
    type = string
    default = ""
}

variable "nexus-image-tag" {
    description = "Nexus image tag, see  https://hub.docker.com/r/sonatype/nexus3/tags for the list of available, requried"
    type = string
}

variable "nexus-targets" {
    description = "A stub to make sure we are running module after EFS targets are ready"
    type = any
}