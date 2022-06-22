variable "bucket_name" {
  description = "Bucket name"
  type        = string
}

variable "storage_class" {
  description = "Storage class"
  type        = string
}

variable "resources" {
  description = "Path to resources files"
  type        = string
}

variable "objects" {
  description = "Objects that will be added to the bucket"
  type        = map(any)
}

variable "region" {
  description = "Region of the bucket"
  type        = string
}

variable "certificate" {
  description = "Name of the certificate"
  type        = string
}

variable "key" {
  description = "Name of the key"
  type        = string
}

variable "static_ip_name" {
  description = "Static IP name"
  type = string
}