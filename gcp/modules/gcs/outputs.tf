output "LB_static_ip" {
    value = google_compute_global_address.static_ip.address
}