resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
  name             = "${var.database_instance_name}-${random_integer.rnd.result}"
  database_version = "POSTGRES_14"
  
  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_compute_global_address.private_ip_address
  ]

  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_self_link
    }
  }
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  name          = "${var.database_instance_name}-private-ip-address"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  address_type  = "INTERNAL"
  ip_version   = "IPV4"
  network       = var.vpc_self_link
  address = "10.4.0.0"
}

################################
# conexion privada a cloud sql #  (comentar para poder hacer el terraform apply, ya que lanza error 403)
################################
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [
    google_compute_global_address.private_ip_address
  ]
}

resource "random_integer" "rnd" {
  min = 1
  max = 1000000
}