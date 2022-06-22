variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "region"{
  description = "Region of the subnets"
  type        = string
}

variable subnet_for_cloud_sql {
  description = "Subnet for cloud SQL"
}