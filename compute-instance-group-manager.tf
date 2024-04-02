resource "google_compute_region_instance_group_manager" "webapp_instance_group_manager" {
  name               = "webapp-instance-group-manager-${random_string.resource_name.result}"
  region               = var.deployment_region
  base_instance_name = "webapp-instance"
  target_size        = 1 # Initial size of the instance group
  lifecycle {
    ignore_changes = [target_size]
  }
  version {
    name = "v1"
    instance_template = google_compute_instance_template.webapp_instance_template.self_link
  }
  named_port {
    name = "http"
    port = 8080
  }
  depends_on = [google_compute_instance_template.webapp_instance_template]
}
