resource "google_sql_database_instance" "db_instance" {
  name             = "db-instance-${random_string.resource_name.result}"
  region           = var.deployment_region
  database_version = var.database_version
  settings {
    tier              = var.database_tier
    disk_size         = var.db_disk_size
    disk_type         = var.db_disk_type
    availability_type = var.availability_type
    ip_configuration {
      ipv4_enabled    = false # Disable public IP
      private_network = google_compute_network.vpc.self_link
    }
    backup_configuration {
      enabled = true
    }
  }
  deletion_protection = false
  depends_on          = [google_compute_subnetwork.db_subnet, google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "cloud_native_app_db" {
  name     = "${var.db_user}-${random_string.resource_name.result}"
  instance = google_sql_database_instance.db_instance.name
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "google_sql_user" "webapp_user" {
  name       = "${var.db_user}-${random_string.resource_name.result}"
  instance   = google_sql_database_instance.db_instance.name
  password   = random_password.db_password.result
}