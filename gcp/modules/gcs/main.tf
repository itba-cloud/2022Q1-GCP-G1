#########################
#         BUCKET        #
#########################
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
  storage_class = var.storage_class

  versioning {
    enabled     = true
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "error.html"
  }

  cors {
    origin          = ["http://${var.bucket_name}"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 2
      with_state = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 7
    }
    action {
      type = "Delete"
    }
  }
}

#########################
#     BUCKET ACCESS     #
#########################
resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.bucket.name
  role   = "READER"
  entity = "allUsers"
  depends_on = [
    google_storage_bucket.bucket
  ]
}

#########################
#     BUCKET OBJECTS    #
#########################
resource "google_storage_bucket_object" "gcs_object" {
  for_each = var.objects

  bucket        = google_storage_bucket.bucket.name
  name          = each.value.filename
  source        = format("${var.resources}/html/%s", each.value.filename) # where is the file located
  content_type  = each.value.content_type

  depends_on = [
    google_storage_bucket.bucket
  ]
}

#########################
#     BACKEND BUCKET    #
#########################
resource "google_compute_backend_bucket" "backend_bucket" {
  name        = "${google_storage_bucket.bucket.name}-backend-bucket"
  bucket_name = google_storage_bucket.bucket.name
  enable_cdn  = true
  depends_on = [
    google_storage_bucket.bucket
  ]
}

#########################
#      LB STATIC IP     #
#########################
resource "google_compute_global_address" "static_ip" {
  name        = var.static_ip_name
  description = "Static external IP address for load balancer"
  address_type  = "EXTERNAL"
}

#########################
#    SSL CERTIFICATE    #  (comentar para poder hacer el terraform apply, ya que no tenemos certificados)
#########################
resource "google_compute_ssl_certificate" "ssl" {
  name        = "${google_storage_bucket.bucket.name}-ssl-certificate"
  private_key = file("${var.resources}/${var.key}")
  certificate = file("${var.resources}/${var.certificate}")
  depends_on = [
    google_storage_bucket.bucket
  ]
}

#########################
#     HTTPS URL_MAP     #  (comentar para poder hacer el terraform apply, ya que no tenemos certificados)
#########################
resource "google_compute_url_map" "static_https" {
  name        = "${google_storage_bucket.bucket.name}-url-map-https"
  default_service = google_compute_backend_bucket.backend_bucket.id
  depends_on = [
    google_compute_backend_bucket.backend_bucket
  ]
}

#########################
#      HTTPS PROXY      #  (comentar para poder hacer el terraform apply, ya que no tenemos certificados)
#########################
resource "google_compute_target_https_proxy" "static_https" {
  name             = "${var.bucket_name}-static-https-proxy"
  url_map          = google_compute_url_map.static_https.id
  ssl_certificates = [google_compute_ssl_certificate.ssl.id]
  depends_on = [
    google_compute_ssl_certificate.ssl,
    google_compute_url_map.static_https
  ]
}

#########################
# HTTPS FORWARDING RULE #  (comentar para poder hacer el terraform apply, ya que no tenemos certificados)
#########################
resource "google_compute_global_forwarding_rule" "static_https" {
  name       = "${var.bucket_name}-static-forwarding-rule-https"
  target     = google_compute_target_https_proxy.static_https.id
  port_range = "443"
  ip_address = google_compute_global_address.static_ip.id
  depends_on = [
    google_compute_target_https_proxy.static_https,
    google_compute_global_address.static_ip
  ]
}


#########################
#     HTTP URL_MAP      #
#########################
# Partial HTTP load balancer redirects to HTTPS
resource "google_compute_url_map" "static_http" {
  name = "${var.bucket_name}-static-http-redirect"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

#########################
#      HTTP PROXY       #
#########################
resource "google_compute_target_http_proxy" "static_http" {
  name    = "${var.bucket_name}-static-http-proxy"
  url_map = google_compute_url_map.static_http.id
  depends_on = [
    google_compute_url_map.static_http
  ]
}

#########################
# HTTP FORWARDING RULE  #
#########################
resource "google_compute_global_forwarding_rule" "static_http" {
  name       = "${var.bucket_name}-static-forwarding-rule-http"
  target     = google_compute_target_http_proxy.static_http.id
  port_range = "80"
  ip_address = google_compute_global_address.static_ip.id
  depends_on = [
    google_compute_target_http_proxy.static_http,
    google_compute_global_address.static_ip
  ]
}