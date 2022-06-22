#########################
#       SERVICES        #
#########################
resource "google_cloud_run_service" "service" {
  for_each = var.services

  name     = each.value.name
  location = var.region

  template {
    spec {
      containers {
        image = each.value.image
      }
    }
  }

  metadata {
      annotations = {
        "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
        "run.googleapis.com/vpc-access-connector" = var.vpc_access_connector_name
      }
    }
}

#########################
#       IAM POLICY      # (comentar para poder hacer el terraform apply, ya que nos tira error 403)
#########################
resource "google_cloud_run_service_iam_binding" "binding" {
  for_each = var.services
  service     = each.value.name
  location = var.region

  role = "roles/run.invoker"
  members = [
    "allUsers",
  ]
  depends_on = [
    google_cloud_run_service.service
  ]
}