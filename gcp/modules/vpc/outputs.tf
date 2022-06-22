output "vpc_name" {
    value = var.vpc_name
}

output "vpc_self_link" {
    value = google_compute_network.vpc.self_link
}

output "vpc_access_connector_name" {
    value = var.vpc_acccess_connector_name
}