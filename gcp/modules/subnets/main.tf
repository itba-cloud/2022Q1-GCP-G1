resource "google_compute_subnetwork" "subnet" {
  name = var.subnet_for_cloud_sql.name
  ip_cidr_range = var.subnet_for_cloud_sql.cidr_range
  network      = var.vpc_name
  region        = var.region
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_30_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}