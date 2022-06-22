variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_acccess_connector_name" {
  description = "VPC Access Connector name"
  type = string
}

variable "vpc_access_connector_ip_cidr_range" {
  description = "VPC Access Connector CIDR range"
  type = string
}