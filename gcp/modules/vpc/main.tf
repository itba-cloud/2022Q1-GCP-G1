resource "google_compute_network" "vpc" {
  name          =  var.vpc_name
  auto_create_subnetworks = "false"  // VPC de tipo custom
}


####################
# Todo lo siguiente es para conseguir Serverless Access Connector
####################

resource "google_project_service" "vpcaccess_api" {
  service  = "vpcaccess.googleapis.com"
  provider = google-beta
  disable_on_destroy = false
}

# VPC access connector
resource "google_vpc_access_connector" "connector" {
  name          = var.vpc_acccess_connector_name
  provider      = google-beta
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.vpc_access_connector_ip_cidr_range
  depends_on    = [
    google_project_service.vpcaccess_api,
    google_compute_network.vpc
  ]
}