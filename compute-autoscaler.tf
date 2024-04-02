resource "google_compute_region_autoscaler" "webapp_autoscaler" {
  name   = "webapp-autoscaler-${random_string.resource_name.result}"
  region = var.deployment_region
  target = google_compute_region_instance_group_manager.webapp_instance_group_manager.self_link
  autoscaling_policy {
    min_replicas = 1
    max_replicas = 2
    cpu_utilization {
      target = 0.10 # 10% CPU usage
    }
    cooldown_period = 60
  }
}
