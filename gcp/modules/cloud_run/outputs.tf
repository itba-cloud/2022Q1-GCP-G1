output "user_service_address" {
    value = google_cloud_run_service.service["user_service"].status.0.url
}

output "post_service_address" {
    value = google_cloud_run_service.service["post_service"].status.0.url
}

output "ama_service_address" {
    value = google_cloud_run_service.service["ask_me_anything_service"].status.0.url
}

output "feed_service_address" {
    value = google_cloud_run_service.service["feed_service"].status.0.url
}