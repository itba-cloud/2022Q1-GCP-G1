variable "api_id" {
  description = "ID of the API"
  type = string
}

variable "api_config_id" {
  description = "ID of the API config"
  type = string
}

variable "api_gw_id" {
  description = "ID of the API GATEWAY"
  type = string
}

variable "api_file_path" {
    description = "API file path"
    type = string
}

variable "static_ip_name" {
  description = "Static IP name"
  type = string
}

variable "certificate" {
  description = "Name of the certificate"
  type        = string
}

variable "key" {
  description = "Name of the key"
  type        = string
}

variable "resources" {
  description = "Path to resources files"
  type        = string
}

variable "user_service_address" {
  description = "User Service address"
}

variable "post_service_address" {
  description = "User Service address"
}

variable "ama_service_address" {
  description = "User Service address"
}

variable "feed_service_address" {
  description = "User Service address"
}