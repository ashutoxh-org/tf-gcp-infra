output "db_host_metadata" {
  description = "Database Host stored in instance metadata"
  value       = google_compute_instance.webapp_instance.metadata["db-host"]
}

output "db_name_metadata" {
  description = "Database Name stored in instance metadata"
  value       = google_compute_instance.webapp_instance.metadata["db-name"]
}

output "db_user_metadata" {
  description = "Database User stored in instance metadata"
  value       = google_compute_instance.webapp_instance.metadata["db-user"]
}

output "db_pass_metadata" {
  description = "Database Password stored in instance metadata"
  value       = google_compute_instance.webapp_instance.metadata["db-pass"]
  sensitive   = true
}

output "webapp_ip" {
  description = "The external IP address of the webapp instance"
  value       = google_compute_instance.webapp_instance.network_interface[0].access_config[0].nat_ip
}