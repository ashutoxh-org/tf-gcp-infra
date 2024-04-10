resource "google_compute_region_autoscaler" "webapp_autoscaler" {
  name   = "webapp-autoscaler-${random_string.resource_name.result}"
  region = var.deployment_region
  target = google_compute_region_instance_group_manager.webapp_instance_group_manager.self_link
  autoscaling_policy {
    min_replicas = 4
    max_replicas = 8
    cpu_utilization {
      target = 0.07 # 7% CPU usage
    }
    cooldown_period = 180
  }
}
