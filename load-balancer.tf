resource "google_compute_managed_ssl_certificate" "webapp_ssl_certificate" {
  name     = "webapp-ssl-certificate-${random_string.resource_name.result}"
  provider = google-beta
  project  = var.project_id
  managed {
    domains = ["ashutoxh.me"]
  }
}

resource "google_compute_health_check" "webapp_health_check" {
  name                = "webapp-health-check-${random_string.resource_name.result}"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  http_health_check {
    port         = "8080"
    request_path = "/healthz"
  }
}

resource "google_compute_backend_service" "webapp_backend_service" {
  name          = "webapp-backend-service-${random_string.resource_name.result}"
  health_checks = [google_compute_health_check.webapp_health_check.self_link]
  backend {
    group = google_compute_region_instance_group_manager.webapp_instance_group_manager.instance_group
  }
  log_config {
    enable      = true
    sample_rate = 1.0 # Log every request. Adjust the sample rate as needed.
  }
}

resource "google_compute_url_map" "webapp_url_map" {
  name            = "webapp-url-map-${random_string.resource_name.result}"
  default_service = google_compute_backend_service.webapp_backend_service.self_link
}

resource "google_compute_target_https_proxy" "webapp_target_https_proxy" {
  name             = "webapp-target-https-proxy-${random_string.resource_name.result}"
  url_map          = google_compute_url_map.webapp_url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.webapp_ssl_certificate.name]
}

resource "google_compute_global_forwarding_rule" "webapp_forwarding_rule" {
  name       = "webapp-forwarding-rule-${random_string.resource_name.result}"
  target     = google_compute_target_https_proxy.webapp_target_https_proxy.self_link
  port_range = "443"
}