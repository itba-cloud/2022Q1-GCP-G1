resource "google_dns_managed_zone" "dns" {
  name     = var.name
  dns_name = var.dns_name
  visibility = "public"
}

resource "google_dns_record_set" "bucket_dns_record" {
  name         = google_dns_managed_zone.dns.dns_name
  managed_zone = google_dns_managed_zone.dns.name
  type         = "A"
  ttl          = var.dns_TTL

  rrdatas = [var.LB_bucket_static_ip]

  depends_on = [
    google_dns_managed_zone.dns
  ]
}