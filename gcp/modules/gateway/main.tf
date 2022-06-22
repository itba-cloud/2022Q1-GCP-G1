resource "google_api_gateway_api" "api_gw" {
  api_id = var.api_id
  provider = google-beta
}

data "template_file" "data" {
  template = "${file(var.api_file_path)}"
  vars = {
    user_service_url  = var.user_service_address
    post_service_url  = var.post_service_address
    ama_service_url  = var.ama_service_address
    feed_service_url  = var.feed_service_address
  }
}

resource "google_api_gateway_api_config" "api_gw" {
  api = google_api_gateway_api.api_gw.api_id
  provider = google-beta
  api_config_id = var.api_config_id

  openapi_documents {
    document {
      path = var.api_file_path
      contents = base64encode(data.template_file.data.rendered)
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    google_api_gateway_api.api_gw
  ]
}

resource "google_api_gateway_gateway" "api_gw" {
  api_config = google_api_gateway_api_config.api_gw.id
  provider = google-beta
  gateway_id = var.api_gw_id
  depends_on = [
    google_api_gateway_api_config.api_gw
  ]
}