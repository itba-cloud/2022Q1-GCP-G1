variable "services" {
    description = "Map of all services"
    type = map(object({
        name = string
        image = string
    }))
}

variable "region" {
    description = "Region of the services"
    type = string
}

variable "vpc_access_connector_name" {
    description = "VPC Access Connector name"
    type = string
}